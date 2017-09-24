
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 87 04 00 00       	call   80051f <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 6a 1e 80 00       	push   $0x801e6a
  800111:	6a 23                	push   $0x23
  800113:	68 87 1e 80 00       	push   $0x801e87
  800118:	e8 27 0f 00 00       	call   801044 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 6a 1e 80 00       	push   $0x801e6a
  800192:	6a 23                	push   $0x23
  800194:	68 87 1e 80 00       	push   $0x801e87
  800199:	e8 a6 0e 00 00       	call   801044 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 6a 1e 80 00       	push   $0x801e6a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 87 1e 80 00       	push   $0x801e87
  8001db:	e8 64 0e 00 00       	call   801044 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 6a 1e 80 00       	push   $0x801e6a
  800216:	6a 23                	push   $0x23
  800218:	68 87 1e 80 00       	push   $0x801e87
  80021d:	e8 22 0e 00 00       	call   801044 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 6a 1e 80 00       	push   $0x801e6a
  800258:	6a 23                	push   $0x23
  80025a:	68 87 1e 80 00       	push   $0x801e87
  80025f:	e8 e0 0d 00 00       	call   801044 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 6a 1e 80 00       	push   $0x801e6a
  80029a:	6a 23                	push   $0x23
  80029c:	68 87 1e 80 00       	push   $0x801e87
  8002a1:	e8 9e 0d 00 00       	call   801044 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 6a 1e 80 00       	push   $0x801e6a
  8002dc:	6a 23                	push   $0x23
  8002de:	68 87 1e 80 00       	push   $0x801e87
  8002e3:	e8 5c 0d 00 00       	call   801044 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 6a 1e 80 00       	push   $0x801e6a
  800340:	6a 23                	push   $0x23
  800342:	68 87 1e 80 00       	push   $0x801e87
  800347:	e8 f8 0c 00 00       	call   801044 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 11                	je     8003a8 <fd_alloc+0x2d>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	75 09                	jne    8003b1 <fd_alloc+0x36>
			*fd_store = fd;
  8003a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003af:	eb 17                	jmp    8003c8 <fd_alloc+0x4d>
  8003b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003bb:	75 c9                	jne    800386 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
  800409:	eb 13                	jmp    80041e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb 0c                	jmp    80041e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 05                	jmp    80041e <fd_lookup+0x54>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba 14 1f 80 00       	mov    $0x801f14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	eb 13                	jmp    800443 <dev_lookup+0x23>
  800430:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	75 0c                	jne    800443 <dev_lookup+0x23>
			*dev = devtab[i];
  800437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	eb 2e                	jmp    800471 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	75 e7                	jne    800430 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800449:	a1 04 40 80 00       	mov    0x804004,%eax
  80044e:	8b 40 48             	mov    0x48(%eax),%eax
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	51                   	push   %ecx
  800455:	50                   	push   %eax
  800456:	68 98 1e 80 00       	push   $0x801e98
  80045b:	e8 bd 0c 00 00       	call   80111d <cprintf>
	*dev = 0;
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 10             	sub    $0x10,%esp
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800484:	50                   	push   %eax
  800485:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048b:	c1 e8 0c             	shr    $0xc,%eax
  80048e:	50                   	push   %eax
  80048f:	e8 36 ff ff ff       	call   8003ca <fd_lookup>
  800494:	83 c4 08             	add    $0x8,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	78 05                	js     8004a0 <fd_close+0x2d>
	    || fd != fd2)
  80049b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80049e:	74 0c                	je     8004ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a0:	84 db                	test   %bl,%bl
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	0f 44 c2             	cmove  %edx,%eax
  8004aa:	eb 41                	jmp    8004ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff 36                	pushl  (%esi)
  8004b5:	e8 66 ff ff ff       	call   800420 <dev_lookup>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 1a                	js     8004dd <fd_close+0x6a>
		if (dev->dev_close)
  8004c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 0b                	je     8004dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d2:	83 ec 0c             	sub    $0xc,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff d0                	call   *%eax
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	6a 00                	push   $0x0
  8004e3:	e8 00 fd ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	89 d8                	mov    %ebx,%eax
}
  8004ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 c4 fe ff ff       	call   8003ca <fd_lookup>
  800506:	83 c4 08             	add    $0x8,%esp
  800509:	85 c0                	test   %eax,%eax
  80050b:	78 10                	js     80051d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	6a 01                	push   $0x1
  800512:	ff 75 f4             	pushl  -0xc(%ebp)
  800515:	e8 59 ff ff ff       	call   800473 <fd_close>
  80051a:	83 c4 10             	add    $0x10,%esp
}
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <close_all>:

void
close_all(void)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	53                   	push   %ebx
  800523:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052b:	83 ec 0c             	sub    $0xc,%esp
  80052e:	53                   	push   %ebx
  80052f:	e8 c0 ff ff ff       	call   8004f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800534:	83 c3 01             	add    $0x1,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	83 fb 20             	cmp    $0x20,%ebx
  80053d:	75 ec                	jne    80052b <close_all+0xc>
		close(i);
}
  80053f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800542:	c9                   	leave  
  800543:	c3                   	ret    

00800544 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	57                   	push   %edi
  800548:	56                   	push   %esi
  800549:	53                   	push   %ebx
  80054a:	83 ec 2c             	sub    $0x2c,%esp
  80054d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800550:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800553:	50                   	push   %eax
  800554:	ff 75 08             	pushl  0x8(%ebp)
  800557:	e8 6e fe ff ff       	call   8003ca <fd_lookup>
  80055c:	83 c4 08             	add    $0x8,%esp
  80055f:	85 c0                	test   %eax,%eax
  800561:	0f 88 c1 00 00 00    	js     800628 <dup+0xe4>
		return r;
	close(newfdnum);
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	56                   	push   %esi
  80056b:	e8 84 ff ff ff       	call   8004f4 <close>

	newfd = INDEX2FD(newfdnum);
  800570:	89 f3                	mov    %esi,%ebx
  800572:	c1 e3 0c             	shl    $0xc,%ebx
  800575:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057b:	83 c4 04             	add    $0x4,%esp
  80057e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800581:	e8 de fd ff ff       	call   800364 <fd2data>
  800586:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800588:	89 1c 24             	mov    %ebx,(%esp)
  80058b:	e8 d4 fd ff ff       	call   800364 <fd2data>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800596:	89 f8                	mov    %edi,%eax
  800598:	c1 e8 16             	shr    $0x16,%eax
  80059b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a2:	a8 01                	test   $0x1,%al
  8005a4:	74 37                	je     8005dd <dup+0x99>
  8005a6:	89 f8                	mov    %edi,%eax
  8005a8:	c1 e8 0c             	shr    $0xc,%eax
  8005ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b2:	f6 c2 01             	test   $0x1,%dl
  8005b5:	74 26                	je     8005dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005be:	83 ec 0c             	sub    $0xc,%esp
  8005c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ca:	6a 00                	push   $0x0
  8005cc:	57                   	push   %edi
  8005cd:	6a 00                	push   $0x0
  8005cf:	e8 d2 fb ff ff       	call   8001a6 <sys_page_map>
  8005d4:	89 c7                	mov    %eax,%edi
  8005d6:	83 c4 20             	add    $0x20,%esp
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	78 2e                	js     80060b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e0:	89 d0                	mov    %edx,%eax
  8005e2:	c1 e8 0c             	shr    $0xc,%eax
  8005e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f4:	50                   	push   %eax
  8005f5:	53                   	push   %ebx
  8005f6:	6a 00                	push   $0x0
  8005f8:	52                   	push   %edx
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 a6 fb ff ff       	call   8001a6 <sys_page_map>
  800600:	89 c7                	mov    %eax,%edi
  800602:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800605:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800607:	85 ff                	test   %edi,%edi
  800609:	79 1d                	jns    800628 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 00                	push   $0x0
  800611:	e8 d2 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061c:	6a 00                	push   $0x0
  80061e:	e8 c5 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	89 f8                	mov    %edi,%eax
}
  800628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5f                   	pop    %edi
  80062e:	5d                   	pop    %ebp
  80062f:	c3                   	ret    

00800630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	53                   	push   %ebx
  80063f:	e8 86 fd ff ff       	call   8003ca <fd_lookup>
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	89 c2                	mov    %eax,%edx
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 6d                	js     8006ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800657:	ff 30                	pushl  (%eax)
  800659:	e8 c2 fd ff ff       	call   800420 <dev_lookup>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 c0                	test   %eax,%eax
  800663:	78 4c                	js     8006b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800665:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800668:	8b 42 08             	mov    0x8(%edx),%eax
  80066b:	83 e0 03             	and    $0x3,%eax
  80066e:	83 f8 01             	cmp    $0x1,%eax
  800671:	75 21                	jne    800694 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800673:	a1 04 40 80 00       	mov    0x804004,%eax
  800678:	8b 40 48             	mov    0x48(%eax),%eax
  80067b:	83 ec 04             	sub    $0x4,%esp
  80067e:	53                   	push   %ebx
  80067f:	50                   	push   %eax
  800680:	68 d9 1e 80 00       	push   $0x801ed9
  800685:	e8 93 0a 00 00       	call   80111d <cprintf>
		return -E_INVAL;
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800692:	eb 26                	jmp    8006ba <read+0x8a>
	}
	if (!dev->dev_read)
  800694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800697:	8b 40 08             	mov    0x8(%eax),%eax
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 17                	je     8006b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80069e:	83 ec 04             	sub    $0x4,%esp
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	52                   	push   %edx
  8006a8:	ff d0                	call   *%eax
  8006aa:	89 c2                	mov    %eax,%edx
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb 09                	jmp    8006ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	eb 05                	jmp    8006ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ba:	89 d0                	mov    %edx,%eax
  8006bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	57                   	push   %edi
  8006c5:	56                   	push   %esi
  8006c6:	53                   	push   %ebx
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	eb 21                	jmp    8006f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d7:	83 ec 04             	sub    $0x4,%esp
  8006da:	89 f0                	mov    %esi,%eax
  8006dc:	29 d8                	sub    %ebx,%eax
  8006de:	50                   	push   %eax
  8006df:	89 d8                	mov    %ebx,%eax
  8006e1:	03 45 0c             	add    0xc(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	57                   	push   %edi
  8006e6:	e8 45 ff ff ff       	call   800630 <read>
		if (m < 0)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	78 10                	js     800702 <readn+0x41>
			return m;
		if (m == 0)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 0a                	je     800700 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f6:	01 c3                	add    %eax,%ebx
  8006f8:	39 f3                	cmp    %esi,%ebx
  8006fa:	72 db                	jb     8006d7 <readn+0x16>
  8006fc:	89 d8                	mov    %ebx,%eax
  8006fe:	eb 02                	jmp    800702 <readn+0x41>
  800700:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	83 ec 14             	sub    $0x14,%esp
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	53                   	push   %ebx
  800719:	e8 ac fc ff ff       	call   8003ca <fd_lookup>
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	89 c2                	mov    %eax,%edx
  800723:	85 c0                	test   %eax,%eax
  800725:	78 68                	js     80078f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 e8 fc ff ff       	call   800420 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 47                	js     800786 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	75 21                	jne    800769 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 04 40 80 00       	mov    0x804004,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 f5 1e 80 00       	push   $0x801ef5
  80075a:	e8 be 09 00 00       	call   80111d <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800767:	eb 26                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076c:	8b 52 0c             	mov    0xc(%edx),%edx
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 17                	je     80078a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	50                   	push   %eax
  80077d:	ff d2                	call   *%edx
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 09                	jmp    80078f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800786:	89 c2                	mov    %eax,%edx
  800788:	eb 05                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078f:	89 d0                	mov    %edx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <seek>:

int
seek(int fdnum, off_t offset)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 22 fc ff ff       	call   8003ca <fd_lookup>
  8007a8:	83 c4 08             	add    $0x8,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 0e                	js     8007bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 14             	sub    $0x14,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 f7 fb ff ff       	call   8003ca <fd_lookup>
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	78 65                	js     800841 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e6:	ff 30                	pushl  (%eax)
  8007e8:	e8 33 fc ff ff       	call   800420 <dev_lookup>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 44                	js     800838 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fb:	75 21                	jne    80081e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007fd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 b8 1e 80 00       	push   $0x801eb8
  80080f:	e8 09 09 00 00       	call   80111d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081c:	eb 23                	jmp    800841 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80081e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800821:	8b 52 18             	mov    0x18(%edx),%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	74 14                	je     80083c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	50                   	push   %eax
  80082f:	ff d2                	call   *%edx
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	eb 09                	jmp    800841 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	89 c2                	mov    %eax,%edx
  80083a:	eb 05                	jmp    800841 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800841:	89 d0                	mov    %edx,%eax
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 14             	sub    $0x14,%esp
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800852:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 6c fb ff ff       	call   8003ca <fd_lookup>
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	89 c2                	mov    %eax,%edx
  800863:	85 c0                	test   %eax,%eax
  800865:	78 58                	js     8008bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800871:	ff 30                	pushl  (%eax)
  800873:	e8 a8 fb ff ff       	call   800420 <dev_lookup>
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 37                	js     8008b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800886:	74 32                	je     8008ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800888:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800892:	00 00 00 
	stat->st_isdir = 0;
  800895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089c:	00 00 00 
	stat->st_dev = dev;
  80089f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ac:	ff 50 14             	call   *0x14(%eax)
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 09                	jmp    8008bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	eb 05                	jmp    8008bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	6a 00                	push   $0x0
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 e9 01 00 00       	call   800ac1 <open>
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 1b                	js     8008fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	50                   	push   %eax
  8008e8:	e8 5b ff ff ff       	call   800848 <fstat>
  8008ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ef:	89 1c 24             	mov    %ebx,(%esp)
  8008f2:	e8 fd fb ff ff       	call   8004f4 <close>
	return r;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 f0                	mov    %esi,%eax
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	89 c6                	mov    %eax,%esi
  80090a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800913:	75 12                	jne    800927 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	6a 01                	push   $0x1
  80091a:	e8 1f 12 00 00       	call   801b3e <ipc_find_env>
  80091f:	a3 00 40 80 00       	mov    %eax,0x804000
  800924:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800927:	6a 07                	push   $0x7
  800929:	68 00 50 80 00       	push   $0x805000
  80092e:	56                   	push   %esi
  80092f:	ff 35 00 40 80 00    	pushl  0x804000
  800935:	e8 b0 11 00 00       	call   801aea <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80093a:	83 c4 0c             	add    $0xc,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	53                   	push   %ebx
  800940:	6a 00                	push   $0x0
  800942:	e8 21 11 00 00       	call   801a68 <ipc_recv>
}
  800947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 40 0c             	mov    0xc(%eax),%eax
  80095a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
  80096c:	b8 02 00 00 00       	mov    $0x2,%eax
  800971:	e8 8d ff ff ff       	call   800903 <fsipc>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 6b ff ff ff       	call   800903 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	83 ec 04             	sub    $0x4,%esp
  8009a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b9:	e8 45 ff ff ff       	call   800903 <fsipc>
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 2c                	js     8009ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	68 00 50 80 00       	push   $0x805000
  8009ca:	53                   	push   %ebx
  8009cb:	e8 51 0d 00 00       	call   801721 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009db:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 0c             	sub    $0xc,%esp
  8009f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fc:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a01:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a06:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a09:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0c:	8b 52 0c             	mov    0xc(%edx),%edx
  800a0f:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800a15:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  800a1a:	50                   	push   %eax
  800a1b:	ff 75 0c             	pushl  0xc(%ebp)
  800a1e:	68 08 50 80 00       	push   $0x805008
  800a23:	e8 8b 0e 00 00       	call   8018b3 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800a28:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2d:	b8 04 00 00 00       	mov    $0x4,%eax
  800a32:	e8 cc fe ff ff       	call   800903 <fsipc>
            return r;

    return r;
}
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8b 40 0c             	mov    0xc(%eax),%eax
  800a47:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a4c:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a52:	ba 00 00 00 00       	mov    $0x0,%edx
  800a57:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5c:	e8 a2 fe ff ff       	call   800903 <fsipc>
  800a61:	89 c3                	mov    %eax,%ebx
  800a63:	85 c0                	test   %eax,%eax
  800a65:	78 51                	js     800ab8 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a67:	39 c6                	cmp    %eax,%esi
  800a69:	73 19                	jae    800a84 <devfile_read+0x4b>
  800a6b:	68 24 1f 80 00       	push   $0x801f24
  800a70:	68 2b 1f 80 00       	push   $0x801f2b
  800a75:	68 82 00 00 00       	push   $0x82
  800a7a:	68 40 1f 80 00       	push   $0x801f40
  800a7f:	e8 c0 05 00 00       	call   801044 <_panic>
	assert(r <= PGSIZE);
  800a84:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a89:	7e 19                	jle    800aa4 <devfile_read+0x6b>
  800a8b:	68 4b 1f 80 00       	push   $0x801f4b
  800a90:	68 2b 1f 80 00       	push   $0x801f2b
  800a95:	68 83 00 00 00       	push   $0x83
  800a9a:	68 40 1f 80 00       	push   $0x801f40
  800a9f:	e8 a0 05 00 00       	call   801044 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa4:	83 ec 04             	sub    $0x4,%esp
  800aa7:	50                   	push   %eax
  800aa8:	68 00 50 80 00       	push   $0x805000
  800aad:	ff 75 0c             	pushl  0xc(%ebp)
  800ab0:	e8 fe 0d 00 00       	call   8018b3 <memmove>
	return r;
  800ab5:	83 c4 10             	add    $0x10,%esp
}
  800ab8:	89 d8                	mov    %ebx,%eax
  800aba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	53                   	push   %ebx
  800ac5:	83 ec 20             	sub    $0x20,%esp
  800ac8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800acb:	53                   	push   %ebx
  800acc:	e8 17 0c 00 00       	call   8016e8 <strlen>
  800ad1:	83 c4 10             	add    $0x10,%esp
  800ad4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad9:	7f 67                	jg     800b42 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800adb:	83 ec 0c             	sub    $0xc,%esp
  800ade:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae1:	50                   	push   %eax
  800ae2:	e8 94 f8 ff ff       	call   80037b <fd_alloc>
  800ae7:	83 c4 10             	add    $0x10,%esp
		return r;
  800aea:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aec:	85 c0                	test   %eax,%eax
  800aee:	78 57                	js     800b47 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800af0:	83 ec 08             	sub    $0x8,%esp
  800af3:	53                   	push   %ebx
  800af4:	68 00 50 80 00       	push   $0x805000
  800af9:	e8 23 0c 00 00       	call   801721 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800afe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b01:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b09:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0e:	e8 f0 fd ff ff       	call   800903 <fsipc>
  800b13:	89 c3                	mov    %eax,%ebx
  800b15:	83 c4 10             	add    $0x10,%esp
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	79 14                	jns    800b30 <open+0x6f>
		fd_close(fd, 0);
  800b1c:	83 ec 08             	sub    $0x8,%esp
  800b1f:	6a 00                	push   $0x0
  800b21:	ff 75 f4             	pushl  -0xc(%ebp)
  800b24:	e8 4a f9 ff ff       	call   800473 <fd_close>
		return r;
  800b29:	83 c4 10             	add    $0x10,%esp
  800b2c:	89 da                	mov    %ebx,%edx
  800b2e:	eb 17                	jmp    800b47 <open+0x86>
	}

	return fd2num(fd);
  800b30:	83 ec 0c             	sub    $0xc,%esp
  800b33:	ff 75 f4             	pushl  -0xc(%ebp)
  800b36:	e8 19 f8 ff ff       	call   800354 <fd2num>
  800b3b:	89 c2                	mov    %eax,%edx
  800b3d:	83 c4 10             	add    $0x10,%esp
  800b40:	eb 05                	jmp    800b47 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b42:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b47:	89 d0                	mov    %edx,%eax
  800b49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4c:	c9                   	leave  
  800b4d:	c3                   	ret    

00800b4e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b54:	ba 00 00 00 00       	mov    $0x0,%edx
  800b59:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5e:	e8 a0 fd ff ff       	call   800903 <fsipc>
}
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b6d:	83 ec 0c             	sub    $0xc,%esp
  800b70:	ff 75 08             	pushl  0x8(%ebp)
  800b73:	e8 ec f7 ff ff       	call   800364 <fd2data>
  800b78:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b7a:	83 c4 08             	add    $0x8,%esp
  800b7d:	68 57 1f 80 00       	push   $0x801f57
  800b82:	53                   	push   %ebx
  800b83:	e8 99 0b 00 00       	call   801721 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b88:	8b 46 04             	mov    0x4(%esi),%eax
  800b8b:	2b 06                	sub    (%esi),%eax
  800b8d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b93:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b9a:	00 00 00 
	stat->st_dev = &devpipe;
  800b9d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ba4:	30 80 00 
	return 0;
}
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bbd:	53                   	push   %ebx
  800bbe:	6a 00                	push   $0x0
  800bc0:	e8 23 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc5:	89 1c 24             	mov    %ebx,(%esp)
  800bc8:	e8 97 f7 ff ff       	call   800364 <fd2data>
  800bcd:	83 c4 08             	add    $0x8,%esp
  800bd0:	50                   	push   %eax
  800bd1:	6a 00                	push   $0x0
  800bd3:	e8 10 f6 ff ff       	call   8001e8 <sys_page_unmap>
}
  800bd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 1c             	sub    $0x1c,%esp
  800be6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800be9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800beb:	a1 04 40 80 00       	mov    0x804004,%eax
  800bf0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf9:	e8 79 0f 00 00       	call   801b77 <pageref>
  800bfe:	89 c3                	mov    %eax,%ebx
  800c00:	89 3c 24             	mov    %edi,(%esp)
  800c03:	e8 6f 0f 00 00       	call   801b77 <pageref>
  800c08:	83 c4 10             	add    $0x10,%esp
  800c0b:	39 c3                	cmp    %eax,%ebx
  800c0d:	0f 94 c1             	sete   %cl
  800c10:	0f b6 c9             	movzbl %cl,%ecx
  800c13:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c16:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c1c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c1f:	39 ce                	cmp    %ecx,%esi
  800c21:	74 1b                	je     800c3e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c23:	39 c3                	cmp    %eax,%ebx
  800c25:	75 c4                	jne    800beb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c27:	8b 42 58             	mov    0x58(%edx),%eax
  800c2a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c2d:	50                   	push   %eax
  800c2e:	56                   	push   %esi
  800c2f:	68 5e 1f 80 00       	push   $0x801f5e
  800c34:	e8 e4 04 00 00       	call   80111d <cprintf>
  800c39:	83 c4 10             	add    $0x10,%esp
  800c3c:	eb ad                	jmp    800beb <_pipeisclosed+0xe>
	}
}
  800c3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	83 ec 28             	sub    $0x28,%esp
  800c52:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c55:	56                   	push   %esi
  800c56:	e8 09 f7 ff ff       	call   800364 <fd2data>
  800c5b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c5d:	83 c4 10             	add    $0x10,%esp
  800c60:	bf 00 00 00 00       	mov    $0x0,%edi
  800c65:	eb 4b                	jmp    800cb2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c67:	89 da                	mov    %ebx,%edx
  800c69:	89 f0                	mov    %esi,%eax
  800c6b:	e8 6d ff ff ff       	call   800bdd <_pipeisclosed>
  800c70:	85 c0                	test   %eax,%eax
  800c72:	75 48                	jne    800cbc <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c74:	e8 cb f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c79:	8b 43 04             	mov    0x4(%ebx),%eax
  800c7c:	8b 0b                	mov    (%ebx),%ecx
  800c7e:	8d 51 20             	lea    0x20(%ecx),%edx
  800c81:	39 d0                	cmp    %edx,%eax
  800c83:	73 e2                	jae    800c67 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c88:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c8c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c8f:	89 c2                	mov    %eax,%edx
  800c91:	c1 fa 1f             	sar    $0x1f,%edx
  800c94:	89 d1                	mov    %edx,%ecx
  800c96:	c1 e9 1b             	shr    $0x1b,%ecx
  800c99:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c9c:	83 e2 1f             	and    $0x1f,%edx
  800c9f:	29 ca                	sub    %ecx,%edx
  800ca1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca9:	83 c0 01             	add    $0x1,%eax
  800cac:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800caf:	83 c7 01             	add    $0x1,%edi
  800cb2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb5:	75 c2                	jne    800c79 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cb7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cba:	eb 05                	jmp    800cc1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cbc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 18             	sub    $0x18,%esp
  800cd2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cd5:	57                   	push   %edi
  800cd6:	e8 89 f6 ff ff       	call   800364 <fd2data>
  800cdb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cdd:	83 c4 10             	add    $0x10,%esp
  800ce0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce5:	eb 3d                	jmp    800d24 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce7:	85 db                	test   %ebx,%ebx
  800ce9:	74 04                	je     800cef <devpipe_read+0x26>
				return i;
  800ceb:	89 d8                	mov    %ebx,%eax
  800ced:	eb 44                	jmp    800d33 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cef:	89 f2                	mov    %esi,%edx
  800cf1:	89 f8                	mov    %edi,%eax
  800cf3:	e8 e5 fe ff ff       	call   800bdd <_pipeisclosed>
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	75 32                	jne    800d2e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cfc:	e8 43 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d01:	8b 06                	mov    (%esi),%eax
  800d03:	3b 46 04             	cmp    0x4(%esi),%eax
  800d06:	74 df                	je     800ce7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d08:	99                   	cltd   
  800d09:	c1 ea 1b             	shr    $0x1b,%edx
  800d0c:	01 d0                	add    %edx,%eax
  800d0e:	83 e0 1f             	and    $0x1f,%eax
  800d11:	29 d0                	sub    %edx,%eax
  800d13:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d1e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d21:	83 c3 01             	add    $0x1,%ebx
  800d24:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d27:	75 d8                	jne    800d01 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d29:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2c:	eb 05                	jmp    800d33 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d2e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d46:	50                   	push   %eax
  800d47:	e8 2f f6 ff ff       	call   80037b <fd_alloc>
  800d4c:	83 c4 10             	add    $0x10,%esp
  800d4f:	89 c2                	mov    %eax,%edx
  800d51:	85 c0                	test   %eax,%eax
  800d53:	0f 88 2c 01 00 00    	js     800e85 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d59:	83 ec 04             	sub    $0x4,%esp
  800d5c:	68 07 04 00 00       	push   $0x407
  800d61:	ff 75 f4             	pushl  -0xc(%ebp)
  800d64:	6a 00                	push   $0x0
  800d66:	e8 f8 f3 ff ff       	call   800163 <sys_page_alloc>
  800d6b:	83 c4 10             	add    $0x10,%esp
  800d6e:	89 c2                	mov    %eax,%edx
  800d70:	85 c0                	test   %eax,%eax
  800d72:	0f 88 0d 01 00 00    	js     800e85 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d7e:	50                   	push   %eax
  800d7f:	e8 f7 f5 ff ff       	call   80037b <fd_alloc>
  800d84:	89 c3                	mov    %eax,%ebx
  800d86:	83 c4 10             	add    $0x10,%esp
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	0f 88 e2 00 00 00    	js     800e73 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d91:	83 ec 04             	sub    $0x4,%esp
  800d94:	68 07 04 00 00       	push   $0x407
  800d99:	ff 75 f0             	pushl  -0x10(%ebp)
  800d9c:	6a 00                	push   $0x0
  800d9e:	e8 c0 f3 ff ff       	call   800163 <sys_page_alloc>
  800da3:	89 c3                	mov    %eax,%ebx
  800da5:	83 c4 10             	add    $0x10,%esp
  800da8:	85 c0                	test   %eax,%eax
  800daa:	0f 88 c3 00 00 00    	js     800e73 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800db0:	83 ec 0c             	sub    $0xc,%esp
  800db3:	ff 75 f4             	pushl  -0xc(%ebp)
  800db6:	e8 a9 f5 ff ff       	call   800364 <fd2data>
  800dbb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbd:	83 c4 0c             	add    $0xc,%esp
  800dc0:	68 07 04 00 00       	push   $0x407
  800dc5:	50                   	push   %eax
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 96 f3 ff ff       	call   800163 <sys_page_alloc>
  800dcd:	89 c3                	mov    %eax,%ebx
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	0f 88 89 00 00 00    	js     800e63 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dda:	83 ec 0c             	sub    $0xc,%esp
  800ddd:	ff 75 f0             	pushl  -0x10(%ebp)
  800de0:	e8 7f f5 ff ff       	call   800364 <fd2data>
  800de5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dec:	50                   	push   %eax
  800ded:	6a 00                	push   $0x0
  800def:	56                   	push   %esi
  800df0:	6a 00                	push   $0x0
  800df2:	e8 af f3 ff ff       	call   8001a6 <sys_page_map>
  800df7:	89 c3                	mov    %eax,%ebx
  800df9:	83 c4 20             	add    $0x20,%esp
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	78 55                	js     800e55 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e00:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e09:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e15:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e23:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e2a:	83 ec 0c             	sub    $0xc,%esp
  800e2d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e30:	e8 1f f5 ff ff       	call   800354 <fd2num>
  800e35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e38:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e3a:	83 c4 04             	add    $0x4,%esp
  800e3d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e40:	e8 0f f5 ff ff       	call   800354 <fd2num>
  800e45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e48:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e4b:	83 c4 10             	add    $0x10,%esp
  800e4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e53:	eb 30                	jmp    800e85 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e55:	83 ec 08             	sub    $0x8,%esp
  800e58:	56                   	push   %esi
  800e59:	6a 00                	push   $0x0
  800e5b:	e8 88 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e60:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e63:	83 ec 08             	sub    $0x8,%esp
  800e66:	ff 75 f0             	pushl  -0x10(%ebp)
  800e69:	6a 00                	push   $0x0
  800e6b:	e8 78 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e70:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e73:	83 ec 08             	sub    $0x8,%esp
  800e76:	ff 75 f4             	pushl  -0xc(%ebp)
  800e79:	6a 00                	push   $0x0
  800e7b:	e8 68 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e85:	89 d0                	mov    %edx,%eax
  800e87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8a:	5b                   	pop    %ebx
  800e8b:	5e                   	pop    %esi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e97:	50                   	push   %eax
  800e98:	ff 75 08             	pushl  0x8(%ebp)
  800e9b:	e8 2a f5 ff ff       	call   8003ca <fd_lookup>
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	78 18                	js     800ebf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ea7:	83 ec 0c             	sub    $0xc,%esp
  800eaa:	ff 75 f4             	pushl  -0xc(%ebp)
  800ead:	e8 b2 f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800eb2:	89 c2                	mov    %eax,%edx
  800eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb7:	e8 21 fd ff ff       	call   800bdd <_pipeisclosed>
  800ebc:	83 c4 10             	add    $0x10,%esp
}
  800ebf:	c9                   	leave  
  800ec0:	c3                   	ret    

00800ec1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ec4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed1:	68 76 1f 80 00       	push   $0x801f76
  800ed6:	ff 75 0c             	pushl  0xc(%ebp)
  800ed9:	e8 43 08 00 00       	call   801721 <strcpy>
	return 0;
}
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    

00800ee5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	57                   	push   %edi
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800efc:	eb 2d                	jmp    800f2b <devcons_write+0x46>
		m = n - tot;
  800efe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f01:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f03:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f06:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f0b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0e:	83 ec 04             	sub    $0x4,%esp
  800f11:	53                   	push   %ebx
  800f12:	03 45 0c             	add    0xc(%ebp),%eax
  800f15:	50                   	push   %eax
  800f16:	57                   	push   %edi
  800f17:	e8 97 09 00 00       	call   8018b3 <memmove>
		sys_cputs(buf, m);
  800f1c:	83 c4 08             	add    $0x8,%esp
  800f1f:	53                   	push   %ebx
  800f20:	57                   	push   %edi
  800f21:	e8 81 f1 ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f26:	01 de                	add    %ebx,%esi
  800f28:	83 c4 10             	add    $0x10,%esp
  800f2b:	89 f0                	mov    %esi,%eax
  800f2d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f30:	72 cc                	jb     800efe <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f35:	5b                   	pop    %ebx
  800f36:	5e                   	pop    %esi
  800f37:	5f                   	pop    %edi
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    

00800f3a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	83 ec 08             	sub    $0x8,%esp
  800f40:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f45:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f49:	74 2a                	je     800f75 <devcons_read+0x3b>
  800f4b:	eb 05                	jmp    800f52 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f4d:	e8 f2 f1 ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f52:	e8 6e f1 ff ff       	call   8000c5 <sys_cgetc>
  800f57:	85 c0                	test   %eax,%eax
  800f59:	74 f2                	je     800f4d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	78 16                	js     800f75 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f5f:	83 f8 04             	cmp    $0x4,%eax
  800f62:	74 0c                	je     800f70 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f67:	88 02                	mov    %al,(%edx)
	return 1;
  800f69:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6e:	eb 05                	jmp    800f75 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f70:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f80:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f83:	6a 01                	push   $0x1
  800f85:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f88:	50                   	push   %eax
  800f89:	e8 19 f1 ff ff       	call   8000a7 <sys_cputs>
}
  800f8e:	83 c4 10             	add    $0x10,%esp
  800f91:	c9                   	leave  
  800f92:	c3                   	ret    

00800f93 <getchar>:

int
getchar(void)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f99:	6a 01                	push   $0x1
  800f9b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9e:	50                   	push   %eax
  800f9f:	6a 00                	push   $0x0
  800fa1:	e8 8a f6 ff ff       	call   800630 <read>
	if (r < 0)
  800fa6:	83 c4 10             	add    $0x10,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 0f                	js     800fbc <getchar+0x29>
		return r;
	if (r < 1)
  800fad:	85 c0                	test   %eax,%eax
  800faf:	7e 06                	jle    800fb7 <getchar+0x24>
		return -E_EOF;
	return c;
  800fb1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fb5:	eb 05                	jmp    800fbc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fb7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fbc:	c9                   	leave  
  800fbd:	c3                   	ret    

00800fbe <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc7:	50                   	push   %eax
  800fc8:	ff 75 08             	pushl  0x8(%ebp)
  800fcb:	e8 fa f3 ff ff       	call   8003ca <fd_lookup>
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	78 11                	js     800fe8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fda:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe0:	39 10                	cmp    %edx,(%eax)
  800fe2:	0f 94 c0             	sete   %al
  800fe5:	0f b6 c0             	movzbl %al,%eax
}
  800fe8:	c9                   	leave  
  800fe9:	c3                   	ret    

00800fea <opencons>:

int
opencons(void)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff3:	50                   	push   %eax
  800ff4:	e8 82 f3 ff ff       	call   80037b <fd_alloc>
  800ff9:	83 c4 10             	add    $0x10,%esp
		return r;
  800ffc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ffe:	85 c0                	test   %eax,%eax
  801000:	78 3e                	js     801040 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801002:	83 ec 04             	sub    $0x4,%esp
  801005:	68 07 04 00 00       	push   $0x407
  80100a:	ff 75 f4             	pushl  -0xc(%ebp)
  80100d:	6a 00                	push   $0x0
  80100f:	e8 4f f1 ff ff       	call   800163 <sys_page_alloc>
  801014:	83 c4 10             	add    $0x10,%esp
		return r;
  801017:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801019:	85 c0                	test   %eax,%eax
  80101b:	78 23                	js     801040 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80101d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801023:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801026:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801028:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	50                   	push   %eax
  801036:	e8 19 f3 ff ff       	call   800354 <fd2num>
  80103b:	89 c2                	mov    %eax,%edx
  80103d:	83 c4 10             	add    $0x10,%esp
}
  801040:	89 d0                	mov    %edx,%eax
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801049:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80104c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801052:	e8 ce f0 ff ff       	call   800125 <sys_getenvid>
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	ff 75 0c             	pushl  0xc(%ebp)
  80105d:	ff 75 08             	pushl  0x8(%ebp)
  801060:	56                   	push   %esi
  801061:	50                   	push   %eax
  801062:	68 84 1f 80 00       	push   $0x801f84
  801067:	e8 b1 00 00 00       	call   80111d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80106c:	83 c4 18             	add    $0x18,%esp
  80106f:	53                   	push   %ebx
  801070:	ff 75 10             	pushl  0x10(%ebp)
  801073:	e8 54 00 00 00       	call   8010cc <vcprintf>
	cprintf("\n");
  801078:	c7 04 24 6f 1f 80 00 	movl   $0x801f6f,(%esp)
  80107f:	e8 99 00 00 00       	call   80111d <cprintf>
  801084:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801087:	cc                   	int3   
  801088:	eb fd                	jmp    801087 <_panic+0x43>

0080108a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	53                   	push   %ebx
  80108e:	83 ec 04             	sub    $0x4,%esp
  801091:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801094:	8b 13                	mov    (%ebx),%edx
  801096:	8d 42 01             	lea    0x1(%edx),%eax
  801099:	89 03                	mov    %eax,(%ebx)
  80109b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a7:	75 1a                	jne    8010c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010a9:	83 ec 08             	sub    $0x8,%esp
  8010ac:	68 ff 00 00 00       	push   $0xff
  8010b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8010b4:	50                   	push   %eax
  8010b5:	e8 ed ef ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8010ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ca:	c9                   	leave  
  8010cb:	c3                   	ret    

008010cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010dc:	00 00 00 
	b.cnt = 0;
  8010df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010e9:	ff 75 0c             	pushl  0xc(%ebp)
  8010ec:	ff 75 08             	pushl  0x8(%ebp)
  8010ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010f5:	50                   	push   %eax
  8010f6:	68 8a 10 80 00       	push   $0x80108a
  8010fb:	e8 1a 01 00 00       	call   80121a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801100:	83 c4 08             	add    $0x8,%esp
  801103:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801109:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80110f:	50                   	push   %eax
  801110:	e8 92 ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  801115:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80111b:	c9                   	leave  
  80111c:	c3                   	ret    

0080111d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801123:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801126:	50                   	push   %eax
  801127:	ff 75 08             	pushl  0x8(%ebp)
  80112a:	e8 9d ff ff ff       	call   8010cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80112f:	c9                   	leave  
  801130:	c3                   	ret    

00801131 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	57                   	push   %edi
  801135:	56                   	push   %esi
  801136:	53                   	push   %ebx
  801137:	83 ec 1c             	sub    $0x1c,%esp
  80113a:	89 c7                	mov    %eax,%edi
  80113c:	89 d6                	mov    %edx,%esi
  80113e:	8b 45 08             	mov    0x8(%ebp),%eax
  801141:	8b 55 0c             	mov    0xc(%ebp),%edx
  801144:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801147:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80114a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80114d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801152:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801155:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801158:	39 d3                	cmp    %edx,%ebx
  80115a:	72 05                	jb     801161 <printnum+0x30>
  80115c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80115f:	77 45                	ja     8011a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801161:	83 ec 0c             	sub    $0xc,%esp
  801164:	ff 75 18             	pushl  0x18(%ebp)
  801167:	8b 45 14             	mov    0x14(%ebp),%eax
  80116a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80116d:	53                   	push   %ebx
  80116e:	ff 75 10             	pushl  0x10(%ebp)
  801171:	83 ec 08             	sub    $0x8,%esp
  801174:	ff 75 e4             	pushl  -0x1c(%ebp)
  801177:	ff 75 e0             	pushl  -0x20(%ebp)
  80117a:	ff 75 dc             	pushl  -0x24(%ebp)
  80117d:	ff 75 d8             	pushl  -0x28(%ebp)
  801180:	e8 3b 0a 00 00       	call   801bc0 <__udivdi3>
  801185:	83 c4 18             	add    $0x18,%esp
  801188:	52                   	push   %edx
  801189:	50                   	push   %eax
  80118a:	89 f2                	mov    %esi,%edx
  80118c:	89 f8                	mov    %edi,%eax
  80118e:	e8 9e ff ff ff       	call   801131 <printnum>
  801193:	83 c4 20             	add    $0x20,%esp
  801196:	eb 18                	jmp    8011b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801198:	83 ec 08             	sub    $0x8,%esp
  80119b:	56                   	push   %esi
  80119c:	ff 75 18             	pushl  0x18(%ebp)
  80119f:	ff d7                	call   *%edi
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	eb 03                	jmp    8011a9 <printnum+0x78>
  8011a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011a9:	83 eb 01             	sub    $0x1,%ebx
  8011ac:	85 db                	test   %ebx,%ebx
  8011ae:	7f e8                	jg     801198 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011b0:	83 ec 08             	sub    $0x8,%esp
  8011b3:	56                   	push   %esi
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c3:	e8 28 0b 00 00       	call   801cf0 <__umoddi3>
  8011c8:	83 c4 14             	add    $0x14,%esp
  8011cb:	0f be 80 a7 1f 80 00 	movsbl 0x801fa7(%eax),%eax
  8011d2:	50                   	push   %eax
  8011d3:	ff d7                	call   *%edi
}
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011db:	5b                   	pop    %ebx
  8011dc:	5e                   	pop    %esi
  8011dd:	5f                   	pop    %edi
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011ea:	8b 10                	mov    (%eax),%edx
  8011ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8011ef:	73 0a                	jae    8011fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8011f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011f4:	89 08                	mov    %ecx,(%eax)
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f9:	88 02                	mov    %al,(%edx)
}
  8011fb:	5d                   	pop    %ebp
  8011fc:	c3                   	ret    

008011fd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801203:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801206:	50                   	push   %eax
  801207:	ff 75 10             	pushl  0x10(%ebp)
  80120a:	ff 75 0c             	pushl  0xc(%ebp)
  80120d:	ff 75 08             	pushl  0x8(%ebp)
  801210:	e8 05 00 00 00       	call   80121a <vprintfmt>
	va_end(ap);
}
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	57                   	push   %edi
  80121e:	56                   	push   %esi
  80121f:	53                   	push   %ebx
  801220:	83 ec 2c             	sub    $0x2c,%esp
  801223:	8b 75 08             	mov    0x8(%ebp),%esi
  801226:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801229:	8b 7d 10             	mov    0x10(%ebp),%edi
  80122c:	eb 12                	jmp    801240 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80122e:	85 c0                	test   %eax,%eax
  801230:	0f 84 42 04 00 00    	je     801678 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801236:	83 ec 08             	sub    $0x8,%esp
  801239:	53                   	push   %ebx
  80123a:	50                   	push   %eax
  80123b:	ff d6                	call   *%esi
  80123d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801240:	83 c7 01             	add    $0x1,%edi
  801243:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801247:	83 f8 25             	cmp    $0x25,%eax
  80124a:	75 e2                	jne    80122e <vprintfmt+0x14>
  80124c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801250:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801257:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80125e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801265:	b9 00 00 00 00       	mov    $0x0,%ecx
  80126a:	eb 07                	jmp    801273 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80126f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801273:	8d 47 01             	lea    0x1(%edi),%eax
  801276:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801279:	0f b6 07             	movzbl (%edi),%eax
  80127c:	0f b6 d0             	movzbl %al,%edx
  80127f:	83 e8 23             	sub    $0x23,%eax
  801282:	3c 55                	cmp    $0x55,%al
  801284:	0f 87 d3 03 00 00    	ja     80165d <vprintfmt+0x443>
  80128a:	0f b6 c0             	movzbl %al,%eax
  80128d:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  801294:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801297:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80129b:	eb d6                	jmp    801273 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012ab:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012af:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012b2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012b5:	83 f9 09             	cmp    $0x9,%ecx
  8012b8:	77 3f                	ja     8012f9 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012bd:	eb e9                	jmp    8012a8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c2:	8b 00                	mov    (%eax),%eax
  8012c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ca:	8d 40 04             	lea    0x4(%eax),%eax
  8012cd:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012d3:	eb 2a                	jmp    8012ff <vprintfmt+0xe5>
  8012d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	ba 00 00 00 00       	mov    $0x0,%edx
  8012df:	0f 49 d0             	cmovns %eax,%edx
  8012e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e8:	eb 89                	jmp    801273 <vprintfmt+0x59>
  8012ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012f4:	e9 7a ff ff ff       	jmp    801273 <vprintfmt+0x59>
  8012f9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801303:	0f 89 6a ff ff ff    	jns    801273 <vprintfmt+0x59>
				width = precision, precision = -1;
  801309:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80130c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80130f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801316:	e9 58 ff ff ff       	jmp    801273 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80131b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801321:	e9 4d ff ff ff       	jmp    801273 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801326:	8b 45 14             	mov    0x14(%ebp),%eax
  801329:	8d 78 04             	lea    0x4(%eax),%edi
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	53                   	push   %ebx
  801330:	ff 30                	pushl  (%eax)
  801332:	ff d6                	call   *%esi
			break;
  801334:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801337:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80133d:	e9 fe fe ff ff       	jmp    801240 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801342:	8b 45 14             	mov    0x14(%ebp),%eax
  801345:	8d 78 04             	lea    0x4(%eax),%edi
  801348:	8b 00                	mov    (%eax),%eax
  80134a:	99                   	cltd   
  80134b:	31 d0                	xor    %edx,%eax
  80134d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80134f:	83 f8 0f             	cmp    $0xf,%eax
  801352:	7f 0b                	jg     80135f <vprintfmt+0x145>
  801354:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  80135b:	85 d2                	test   %edx,%edx
  80135d:	75 1b                	jne    80137a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80135f:	50                   	push   %eax
  801360:	68 bf 1f 80 00       	push   $0x801fbf
  801365:	53                   	push   %ebx
  801366:	56                   	push   %esi
  801367:	e8 91 fe ff ff       	call   8011fd <printfmt>
  80136c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80136f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801375:	e9 c6 fe ff ff       	jmp    801240 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80137a:	52                   	push   %edx
  80137b:	68 3d 1f 80 00       	push   $0x801f3d
  801380:	53                   	push   %ebx
  801381:	56                   	push   %esi
  801382:	e8 76 fe ff ff       	call   8011fd <printfmt>
  801387:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80138a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801390:	e9 ab fe ff ff       	jmp    801240 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801395:	8b 45 14             	mov    0x14(%ebp),%eax
  801398:	83 c0 04             	add    $0x4,%eax
  80139b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80139e:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013a3:	85 ff                	test   %edi,%edi
  8013a5:	b8 b8 1f 80 00       	mov    $0x801fb8,%eax
  8013aa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013b1:	0f 8e 94 00 00 00    	jle    80144b <vprintfmt+0x231>
  8013b7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013bb:	0f 84 98 00 00 00    	je     801459 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c1:	83 ec 08             	sub    $0x8,%esp
  8013c4:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c7:	57                   	push   %edi
  8013c8:	e8 33 03 00 00       	call   801700 <strnlen>
  8013cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013d0:	29 c1                	sub    %eax,%ecx
  8013d2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013d5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013d8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013df:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013e2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e4:	eb 0f                	jmp    8013f5 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	53                   	push   %ebx
  8013ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8013ed:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ef:	83 ef 01             	sub    $0x1,%edi
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	85 ff                	test   %edi,%edi
  8013f7:	7f ed                	jg     8013e6 <vprintfmt+0x1cc>
  8013f9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013fc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013ff:	85 c9                	test   %ecx,%ecx
  801401:	b8 00 00 00 00       	mov    $0x0,%eax
  801406:	0f 49 c1             	cmovns %ecx,%eax
  801409:	29 c1                	sub    %eax,%ecx
  80140b:	89 75 08             	mov    %esi,0x8(%ebp)
  80140e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801411:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801414:	89 cb                	mov    %ecx,%ebx
  801416:	eb 4d                	jmp    801465 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801418:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80141c:	74 1b                	je     801439 <vprintfmt+0x21f>
  80141e:	0f be c0             	movsbl %al,%eax
  801421:	83 e8 20             	sub    $0x20,%eax
  801424:	83 f8 5e             	cmp    $0x5e,%eax
  801427:	76 10                	jbe    801439 <vprintfmt+0x21f>
					putch('?', putdat);
  801429:	83 ec 08             	sub    $0x8,%esp
  80142c:	ff 75 0c             	pushl  0xc(%ebp)
  80142f:	6a 3f                	push   $0x3f
  801431:	ff 55 08             	call   *0x8(%ebp)
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	eb 0d                	jmp    801446 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801439:	83 ec 08             	sub    $0x8,%esp
  80143c:	ff 75 0c             	pushl  0xc(%ebp)
  80143f:	52                   	push   %edx
  801440:	ff 55 08             	call   *0x8(%ebp)
  801443:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801446:	83 eb 01             	sub    $0x1,%ebx
  801449:	eb 1a                	jmp    801465 <vprintfmt+0x24b>
  80144b:	89 75 08             	mov    %esi,0x8(%ebp)
  80144e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801451:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801454:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801457:	eb 0c                	jmp    801465 <vprintfmt+0x24b>
  801459:	89 75 08             	mov    %esi,0x8(%ebp)
  80145c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80145f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801462:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801465:	83 c7 01             	add    $0x1,%edi
  801468:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80146c:	0f be d0             	movsbl %al,%edx
  80146f:	85 d2                	test   %edx,%edx
  801471:	74 23                	je     801496 <vprintfmt+0x27c>
  801473:	85 f6                	test   %esi,%esi
  801475:	78 a1                	js     801418 <vprintfmt+0x1fe>
  801477:	83 ee 01             	sub    $0x1,%esi
  80147a:	79 9c                	jns    801418 <vprintfmt+0x1fe>
  80147c:	89 df                	mov    %ebx,%edi
  80147e:	8b 75 08             	mov    0x8(%ebp),%esi
  801481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801484:	eb 18                	jmp    80149e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801486:	83 ec 08             	sub    $0x8,%esp
  801489:	53                   	push   %ebx
  80148a:	6a 20                	push   $0x20
  80148c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80148e:	83 ef 01             	sub    $0x1,%edi
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	eb 08                	jmp    80149e <vprintfmt+0x284>
  801496:	89 df                	mov    %ebx,%edi
  801498:	8b 75 08             	mov    0x8(%ebp),%esi
  80149b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80149e:	85 ff                	test   %edi,%edi
  8014a0:	7f e4                	jg     801486 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8014a5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014ab:	e9 90 fd ff ff       	jmp    801240 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014b0:	83 f9 01             	cmp    $0x1,%ecx
  8014b3:	7e 19                	jle    8014ce <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b8:	8b 50 04             	mov    0x4(%eax),%edx
  8014bb:	8b 00                	mov    (%eax),%eax
  8014bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c6:	8d 40 08             	lea    0x8(%eax),%eax
  8014c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8014cc:	eb 38                	jmp    801506 <vprintfmt+0x2ec>
	else if (lflag)
  8014ce:	85 c9                	test   %ecx,%ecx
  8014d0:	74 1b                	je     8014ed <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d5:	8b 00                	mov    (%eax),%eax
  8014d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014da:	89 c1                	mov    %eax,%ecx
  8014dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8014df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e5:	8d 40 04             	lea    0x4(%eax),%eax
  8014e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8014eb:	eb 19                	jmp    801506 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f0:	8b 00                	mov    (%eax),%eax
  8014f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f5:	89 c1                	mov    %eax,%ecx
  8014f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8014fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801500:	8d 40 04             	lea    0x4(%eax),%eax
  801503:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801506:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801509:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80150c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801511:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801515:	0f 89 0e 01 00 00    	jns    801629 <vprintfmt+0x40f>
				putch('-', putdat);
  80151b:	83 ec 08             	sub    $0x8,%esp
  80151e:	53                   	push   %ebx
  80151f:	6a 2d                	push   $0x2d
  801521:	ff d6                	call   *%esi
				num = -(long long) num;
  801523:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801526:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801529:	f7 da                	neg    %edx
  80152b:	83 d1 00             	adc    $0x0,%ecx
  80152e:	f7 d9                	neg    %ecx
  801530:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801533:	b8 0a 00 00 00       	mov    $0xa,%eax
  801538:	e9 ec 00 00 00       	jmp    801629 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80153d:	83 f9 01             	cmp    $0x1,%ecx
  801540:	7e 18                	jle    80155a <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801542:	8b 45 14             	mov    0x14(%ebp),%eax
  801545:	8b 10                	mov    (%eax),%edx
  801547:	8b 48 04             	mov    0x4(%eax),%ecx
  80154a:	8d 40 08             	lea    0x8(%eax),%eax
  80154d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801550:	b8 0a 00 00 00       	mov    $0xa,%eax
  801555:	e9 cf 00 00 00       	jmp    801629 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80155a:	85 c9                	test   %ecx,%ecx
  80155c:	74 1a                	je     801578 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80155e:	8b 45 14             	mov    0x14(%ebp),%eax
  801561:	8b 10                	mov    (%eax),%edx
  801563:	b9 00 00 00 00       	mov    $0x0,%ecx
  801568:	8d 40 04             	lea    0x4(%eax),%eax
  80156b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80156e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801573:	e9 b1 00 00 00       	jmp    801629 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801578:	8b 45 14             	mov    0x14(%ebp),%eax
  80157b:	8b 10                	mov    (%eax),%edx
  80157d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801582:	8d 40 04             	lea    0x4(%eax),%eax
  801585:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801588:	b8 0a 00 00 00       	mov    $0xa,%eax
  80158d:	e9 97 00 00 00       	jmp    801629 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801592:	83 ec 08             	sub    $0x8,%esp
  801595:	53                   	push   %ebx
  801596:	6a 58                	push   $0x58
  801598:	ff d6                	call   *%esi
			putch('X', putdat);
  80159a:	83 c4 08             	add    $0x8,%esp
  80159d:	53                   	push   %ebx
  80159e:	6a 58                	push   $0x58
  8015a0:	ff d6                	call   *%esi
			putch('X', putdat);
  8015a2:	83 c4 08             	add    $0x8,%esp
  8015a5:	53                   	push   %ebx
  8015a6:	6a 58                	push   $0x58
  8015a8:	ff d6                	call   *%esi
			break;
  8015aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015b0:	e9 8b fc ff ff       	jmp    801240 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015b5:	83 ec 08             	sub    $0x8,%esp
  8015b8:	53                   	push   %ebx
  8015b9:	6a 30                	push   $0x30
  8015bb:	ff d6                	call   *%esi
			putch('x', putdat);
  8015bd:	83 c4 08             	add    $0x8,%esp
  8015c0:	53                   	push   %ebx
  8015c1:	6a 78                	push   $0x78
  8015c3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c8:	8b 10                	mov    (%eax),%edx
  8015ca:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015cf:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015d2:	8d 40 04             	lea    0x4(%eax),%eax
  8015d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015d8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015dd:	eb 4a                	jmp    801629 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015df:	83 f9 01             	cmp    $0x1,%ecx
  8015e2:	7e 15                	jle    8015f9 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e7:	8b 10                	mov    (%eax),%edx
  8015e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8015ec:	8d 40 08             	lea    0x8(%eax),%eax
  8015ef:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015f2:	b8 10 00 00 00       	mov    $0x10,%eax
  8015f7:	eb 30                	jmp    801629 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015f9:	85 c9                	test   %ecx,%ecx
  8015fb:	74 17                	je     801614 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8015fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801600:	8b 10                	mov    (%eax),%edx
  801602:	b9 00 00 00 00       	mov    $0x0,%ecx
  801607:	8d 40 04             	lea    0x4(%eax),%eax
  80160a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80160d:	b8 10 00 00 00       	mov    $0x10,%eax
  801612:	eb 15                	jmp    801629 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801614:	8b 45 14             	mov    0x14(%ebp),%eax
  801617:	8b 10                	mov    (%eax),%edx
  801619:	b9 00 00 00 00       	mov    $0x0,%ecx
  80161e:	8d 40 04             	lea    0x4(%eax),%eax
  801621:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801624:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801629:	83 ec 0c             	sub    $0xc,%esp
  80162c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801630:	57                   	push   %edi
  801631:	ff 75 e0             	pushl  -0x20(%ebp)
  801634:	50                   	push   %eax
  801635:	51                   	push   %ecx
  801636:	52                   	push   %edx
  801637:	89 da                	mov    %ebx,%edx
  801639:	89 f0                	mov    %esi,%eax
  80163b:	e8 f1 fa ff ff       	call   801131 <printnum>
			break;
  801640:	83 c4 20             	add    $0x20,%esp
  801643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801646:	e9 f5 fb ff ff       	jmp    801240 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	53                   	push   %ebx
  80164f:	52                   	push   %edx
  801650:	ff d6                	call   *%esi
			break;
  801652:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801655:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801658:	e9 e3 fb ff ff       	jmp    801240 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	53                   	push   %ebx
  801661:	6a 25                	push   $0x25
  801663:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	eb 03                	jmp    80166d <vprintfmt+0x453>
  80166a:	83 ef 01             	sub    $0x1,%edi
  80166d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801671:	75 f7                	jne    80166a <vprintfmt+0x450>
  801673:	e9 c8 fb ff ff       	jmp    801240 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5e                   	pop    %esi
  80167d:	5f                   	pop    %edi
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	83 ec 18             	sub    $0x18,%esp
  801686:	8b 45 08             	mov    0x8(%ebp),%eax
  801689:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80168c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80168f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801693:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801696:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80169d:	85 c0                	test   %eax,%eax
  80169f:	74 26                	je     8016c7 <vsnprintf+0x47>
  8016a1:	85 d2                	test   %edx,%edx
  8016a3:	7e 22                	jle    8016c7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016a5:	ff 75 14             	pushl  0x14(%ebp)
  8016a8:	ff 75 10             	pushl  0x10(%ebp)
  8016ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016ae:	50                   	push   %eax
  8016af:	68 e0 11 80 00       	push   $0x8011e0
  8016b4:	e8 61 fb ff ff       	call   80121a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016bc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	eb 05                	jmp    8016cc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016cc:	c9                   	leave  
  8016cd:	c3                   	ret    

008016ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016d4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016d7:	50                   	push   %eax
  8016d8:	ff 75 10             	pushl  0x10(%ebp)
  8016db:	ff 75 0c             	pushl  0xc(%ebp)
  8016de:	ff 75 08             	pushl  0x8(%ebp)
  8016e1:	e8 9a ff ff ff       	call   801680 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f3:	eb 03                	jmp    8016f8 <strlen+0x10>
		n++;
  8016f5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016f8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016fc:	75 f7                	jne    8016f5 <strlen+0xd>
		n++;
	return n;
}
  8016fe:	5d                   	pop    %ebp
  8016ff:	c3                   	ret    

00801700 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801706:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801709:	ba 00 00 00 00       	mov    $0x0,%edx
  80170e:	eb 03                	jmp    801713 <strnlen+0x13>
		n++;
  801710:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801713:	39 c2                	cmp    %eax,%edx
  801715:	74 08                	je     80171f <strnlen+0x1f>
  801717:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80171b:	75 f3                	jne    801710 <strnlen+0x10>
  80171d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80171f:	5d                   	pop    %ebp
  801720:	c3                   	ret    

00801721 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	53                   	push   %ebx
  801725:	8b 45 08             	mov    0x8(%ebp),%eax
  801728:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80172b:	89 c2                	mov    %eax,%edx
  80172d:	83 c2 01             	add    $0x1,%edx
  801730:	83 c1 01             	add    $0x1,%ecx
  801733:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801737:	88 5a ff             	mov    %bl,-0x1(%edx)
  80173a:	84 db                	test   %bl,%bl
  80173c:	75 ef                	jne    80172d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80173e:	5b                   	pop    %ebx
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    

00801741 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	53                   	push   %ebx
  801745:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801748:	53                   	push   %ebx
  801749:	e8 9a ff ff ff       	call   8016e8 <strlen>
  80174e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801751:	ff 75 0c             	pushl  0xc(%ebp)
  801754:	01 d8                	add    %ebx,%eax
  801756:	50                   	push   %eax
  801757:	e8 c5 ff ff ff       	call   801721 <strcpy>
	return dst;
}
  80175c:	89 d8                	mov    %ebx,%eax
  80175e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	56                   	push   %esi
  801767:	53                   	push   %ebx
  801768:	8b 75 08             	mov    0x8(%ebp),%esi
  80176b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176e:	89 f3                	mov    %esi,%ebx
  801770:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801773:	89 f2                	mov    %esi,%edx
  801775:	eb 0f                	jmp    801786 <strncpy+0x23>
		*dst++ = *src;
  801777:	83 c2 01             	add    $0x1,%edx
  80177a:	0f b6 01             	movzbl (%ecx),%eax
  80177d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801780:	80 39 01             	cmpb   $0x1,(%ecx)
  801783:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801786:	39 da                	cmp    %ebx,%edx
  801788:	75 ed                	jne    801777 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80178a:	89 f0                	mov    %esi,%eax
  80178c:	5b                   	pop    %ebx
  80178d:	5e                   	pop    %esi
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	56                   	push   %esi
  801794:	53                   	push   %ebx
  801795:	8b 75 08             	mov    0x8(%ebp),%esi
  801798:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80179b:	8b 55 10             	mov    0x10(%ebp),%edx
  80179e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017a0:	85 d2                	test   %edx,%edx
  8017a2:	74 21                	je     8017c5 <strlcpy+0x35>
  8017a4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017a8:	89 f2                	mov    %esi,%edx
  8017aa:	eb 09                	jmp    8017b5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017ac:	83 c2 01             	add    $0x1,%edx
  8017af:	83 c1 01             	add    $0x1,%ecx
  8017b2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017b5:	39 c2                	cmp    %eax,%edx
  8017b7:	74 09                	je     8017c2 <strlcpy+0x32>
  8017b9:	0f b6 19             	movzbl (%ecx),%ebx
  8017bc:	84 db                	test   %bl,%bl
  8017be:	75 ec                	jne    8017ac <strlcpy+0x1c>
  8017c0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017c2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017c5:	29 f0                	sub    %esi,%eax
}
  8017c7:	5b                   	pop    %ebx
  8017c8:	5e                   	pop    %esi
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    

008017cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017d4:	eb 06                	jmp    8017dc <strcmp+0x11>
		p++, q++;
  8017d6:	83 c1 01             	add    $0x1,%ecx
  8017d9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017dc:	0f b6 01             	movzbl (%ecx),%eax
  8017df:	84 c0                	test   %al,%al
  8017e1:	74 04                	je     8017e7 <strcmp+0x1c>
  8017e3:	3a 02                	cmp    (%edx),%al
  8017e5:	74 ef                	je     8017d6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e7:	0f b6 c0             	movzbl %al,%eax
  8017ea:	0f b6 12             	movzbl (%edx),%edx
  8017ed:	29 d0                	sub    %edx,%eax
}
  8017ef:	5d                   	pop    %ebp
  8017f0:	c3                   	ret    

008017f1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	53                   	push   %ebx
  8017f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017fb:	89 c3                	mov    %eax,%ebx
  8017fd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801800:	eb 06                	jmp    801808 <strncmp+0x17>
		n--, p++, q++;
  801802:	83 c0 01             	add    $0x1,%eax
  801805:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801808:	39 d8                	cmp    %ebx,%eax
  80180a:	74 15                	je     801821 <strncmp+0x30>
  80180c:	0f b6 08             	movzbl (%eax),%ecx
  80180f:	84 c9                	test   %cl,%cl
  801811:	74 04                	je     801817 <strncmp+0x26>
  801813:	3a 0a                	cmp    (%edx),%cl
  801815:	74 eb                	je     801802 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801817:	0f b6 00             	movzbl (%eax),%eax
  80181a:	0f b6 12             	movzbl (%edx),%edx
  80181d:	29 d0                	sub    %edx,%eax
  80181f:	eb 05                	jmp    801826 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801821:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801826:	5b                   	pop    %ebx
  801827:	5d                   	pop    %ebp
  801828:	c3                   	ret    

00801829 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	8b 45 08             	mov    0x8(%ebp),%eax
  80182f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801833:	eb 07                	jmp    80183c <strchr+0x13>
		if (*s == c)
  801835:	38 ca                	cmp    %cl,%dl
  801837:	74 0f                	je     801848 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801839:	83 c0 01             	add    $0x1,%eax
  80183c:	0f b6 10             	movzbl (%eax),%edx
  80183f:	84 d2                	test   %dl,%dl
  801841:	75 f2                	jne    801835 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801843:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	8b 45 08             	mov    0x8(%ebp),%eax
  801850:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801854:	eb 03                	jmp    801859 <strfind+0xf>
  801856:	83 c0 01             	add    $0x1,%eax
  801859:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80185c:	38 ca                	cmp    %cl,%dl
  80185e:	74 04                	je     801864 <strfind+0x1a>
  801860:	84 d2                	test   %dl,%dl
  801862:	75 f2                	jne    801856 <strfind+0xc>
			break;
	return (char *) s;
}
  801864:	5d                   	pop    %ebp
  801865:	c3                   	ret    

00801866 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	57                   	push   %edi
  80186a:	56                   	push   %esi
  80186b:	53                   	push   %ebx
  80186c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80186f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801872:	85 c9                	test   %ecx,%ecx
  801874:	74 36                	je     8018ac <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801876:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80187c:	75 28                	jne    8018a6 <memset+0x40>
  80187e:	f6 c1 03             	test   $0x3,%cl
  801881:	75 23                	jne    8018a6 <memset+0x40>
		c &= 0xFF;
  801883:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801887:	89 d3                	mov    %edx,%ebx
  801889:	c1 e3 08             	shl    $0x8,%ebx
  80188c:	89 d6                	mov    %edx,%esi
  80188e:	c1 e6 18             	shl    $0x18,%esi
  801891:	89 d0                	mov    %edx,%eax
  801893:	c1 e0 10             	shl    $0x10,%eax
  801896:	09 f0                	or     %esi,%eax
  801898:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80189a:	89 d8                	mov    %ebx,%eax
  80189c:	09 d0                	or     %edx,%eax
  80189e:	c1 e9 02             	shr    $0x2,%ecx
  8018a1:	fc                   	cld    
  8018a2:	f3 ab                	rep stos %eax,%es:(%edi)
  8018a4:	eb 06                	jmp    8018ac <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a9:	fc                   	cld    
  8018aa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018ac:	89 f8                	mov    %edi,%eax
  8018ae:	5b                   	pop    %ebx
  8018af:	5e                   	pop    %esi
  8018b0:	5f                   	pop    %edi
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	57                   	push   %edi
  8018b7:	56                   	push   %esi
  8018b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018c1:	39 c6                	cmp    %eax,%esi
  8018c3:	73 35                	jae    8018fa <memmove+0x47>
  8018c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018c8:	39 d0                	cmp    %edx,%eax
  8018ca:	73 2e                	jae    8018fa <memmove+0x47>
		s += n;
		d += n;
  8018cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018cf:	89 d6                	mov    %edx,%esi
  8018d1:	09 fe                	or     %edi,%esi
  8018d3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018d9:	75 13                	jne    8018ee <memmove+0x3b>
  8018db:	f6 c1 03             	test   $0x3,%cl
  8018de:	75 0e                	jne    8018ee <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018e0:	83 ef 04             	sub    $0x4,%edi
  8018e3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018e6:	c1 e9 02             	shr    $0x2,%ecx
  8018e9:	fd                   	std    
  8018ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ec:	eb 09                	jmp    8018f7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018ee:	83 ef 01             	sub    $0x1,%edi
  8018f1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018f4:	fd                   	std    
  8018f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018f7:	fc                   	cld    
  8018f8:	eb 1d                	jmp    801917 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018fa:	89 f2                	mov    %esi,%edx
  8018fc:	09 c2                	or     %eax,%edx
  8018fe:	f6 c2 03             	test   $0x3,%dl
  801901:	75 0f                	jne    801912 <memmove+0x5f>
  801903:	f6 c1 03             	test   $0x3,%cl
  801906:	75 0a                	jne    801912 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801908:	c1 e9 02             	shr    $0x2,%ecx
  80190b:	89 c7                	mov    %eax,%edi
  80190d:	fc                   	cld    
  80190e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801910:	eb 05                	jmp    801917 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801912:	89 c7                	mov    %eax,%edi
  801914:	fc                   	cld    
  801915:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801917:	5e                   	pop    %esi
  801918:	5f                   	pop    %edi
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    

0080191b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80191e:	ff 75 10             	pushl  0x10(%ebp)
  801921:	ff 75 0c             	pushl  0xc(%ebp)
  801924:	ff 75 08             	pushl  0x8(%ebp)
  801927:	e8 87 ff ff ff       	call   8018b3 <memmove>
}
  80192c:	c9                   	leave  
  80192d:	c3                   	ret    

0080192e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	56                   	push   %esi
  801932:	53                   	push   %ebx
  801933:	8b 45 08             	mov    0x8(%ebp),%eax
  801936:	8b 55 0c             	mov    0xc(%ebp),%edx
  801939:	89 c6                	mov    %eax,%esi
  80193b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80193e:	eb 1a                	jmp    80195a <memcmp+0x2c>
		if (*s1 != *s2)
  801940:	0f b6 08             	movzbl (%eax),%ecx
  801943:	0f b6 1a             	movzbl (%edx),%ebx
  801946:	38 d9                	cmp    %bl,%cl
  801948:	74 0a                	je     801954 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80194a:	0f b6 c1             	movzbl %cl,%eax
  80194d:	0f b6 db             	movzbl %bl,%ebx
  801950:	29 d8                	sub    %ebx,%eax
  801952:	eb 0f                	jmp    801963 <memcmp+0x35>
		s1++, s2++;
  801954:	83 c0 01             	add    $0x1,%eax
  801957:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80195a:	39 f0                	cmp    %esi,%eax
  80195c:	75 e2                	jne    801940 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80195e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801963:	5b                   	pop    %ebx
  801964:	5e                   	pop    %esi
  801965:	5d                   	pop    %ebp
  801966:	c3                   	ret    

00801967 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	53                   	push   %ebx
  80196b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80196e:	89 c1                	mov    %eax,%ecx
  801970:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801973:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801977:	eb 0a                	jmp    801983 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801979:	0f b6 10             	movzbl (%eax),%edx
  80197c:	39 da                	cmp    %ebx,%edx
  80197e:	74 07                	je     801987 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801980:	83 c0 01             	add    $0x1,%eax
  801983:	39 c8                	cmp    %ecx,%eax
  801985:	72 f2                	jb     801979 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801987:	5b                   	pop    %ebx
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	57                   	push   %edi
  80198e:	56                   	push   %esi
  80198f:	53                   	push   %ebx
  801990:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801993:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801996:	eb 03                	jmp    80199b <strtol+0x11>
		s++;
  801998:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80199b:	0f b6 01             	movzbl (%ecx),%eax
  80199e:	3c 20                	cmp    $0x20,%al
  8019a0:	74 f6                	je     801998 <strtol+0xe>
  8019a2:	3c 09                	cmp    $0x9,%al
  8019a4:	74 f2                	je     801998 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019a6:	3c 2b                	cmp    $0x2b,%al
  8019a8:	75 0a                	jne    8019b4 <strtol+0x2a>
		s++;
  8019aa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019ad:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b2:	eb 11                	jmp    8019c5 <strtol+0x3b>
  8019b4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019b9:	3c 2d                	cmp    $0x2d,%al
  8019bb:	75 08                	jne    8019c5 <strtol+0x3b>
		s++, neg = 1;
  8019bd:	83 c1 01             	add    $0x1,%ecx
  8019c0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019c5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019cb:	75 15                	jne    8019e2 <strtol+0x58>
  8019cd:	80 39 30             	cmpb   $0x30,(%ecx)
  8019d0:	75 10                	jne    8019e2 <strtol+0x58>
  8019d2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019d6:	75 7c                	jne    801a54 <strtol+0xca>
		s += 2, base = 16;
  8019d8:	83 c1 02             	add    $0x2,%ecx
  8019db:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019e0:	eb 16                	jmp    8019f8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019e2:	85 db                	test   %ebx,%ebx
  8019e4:	75 12                	jne    8019f8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019e6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019eb:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ee:	75 08                	jne    8019f8 <strtol+0x6e>
		s++, base = 8;
  8019f0:	83 c1 01             	add    $0x1,%ecx
  8019f3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a00:	0f b6 11             	movzbl (%ecx),%edx
  801a03:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a06:	89 f3                	mov    %esi,%ebx
  801a08:	80 fb 09             	cmp    $0x9,%bl
  801a0b:	77 08                	ja     801a15 <strtol+0x8b>
			dig = *s - '0';
  801a0d:	0f be d2             	movsbl %dl,%edx
  801a10:	83 ea 30             	sub    $0x30,%edx
  801a13:	eb 22                	jmp    801a37 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a15:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a18:	89 f3                	mov    %esi,%ebx
  801a1a:	80 fb 19             	cmp    $0x19,%bl
  801a1d:	77 08                	ja     801a27 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a1f:	0f be d2             	movsbl %dl,%edx
  801a22:	83 ea 57             	sub    $0x57,%edx
  801a25:	eb 10                	jmp    801a37 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a27:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a2a:	89 f3                	mov    %esi,%ebx
  801a2c:	80 fb 19             	cmp    $0x19,%bl
  801a2f:	77 16                	ja     801a47 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a31:	0f be d2             	movsbl %dl,%edx
  801a34:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a37:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a3a:	7d 0b                	jge    801a47 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a3c:	83 c1 01             	add    $0x1,%ecx
  801a3f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a43:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a45:	eb b9                	jmp    801a00 <strtol+0x76>

	if (endptr)
  801a47:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a4b:	74 0d                	je     801a5a <strtol+0xd0>
		*endptr = (char *) s;
  801a4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a50:	89 0e                	mov    %ecx,(%esi)
  801a52:	eb 06                	jmp    801a5a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a54:	85 db                	test   %ebx,%ebx
  801a56:	74 98                	je     8019f0 <strtol+0x66>
  801a58:	eb 9e                	jmp    8019f8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a5a:	89 c2                	mov    %eax,%edx
  801a5c:	f7 da                	neg    %edx
  801a5e:	85 ff                	test   %edi,%edi
  801a60:	0f 45 c2             	cmovne %edx,%eax
}
  801a63:	5b                   	pop    %ebx
  801a64:	5e                   	pop    %esi
  801a65:	5f                   	pop    %edi
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    

00801a68 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	57                   	push   %edi
  801a6c:	56                   	push   %esi
  801a6d:	53                   	push   %ebx
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	8b 75 08             	mov    0x8(%ebp),%esi
  801a74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801a7a:	85 f6                	test   %esi,%esi
  801a7c:	74 06                	je     801a84 <ipc_recv+0x1c>
		*from_env_store = 0;
  801a7e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801a84:	85 db                	test   %ebx,%ebx
  801a86:	74 06                	je     801a8e <ipc_recv+0x26>
		*perm_store = 0;
  801a88:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801a8e:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801a90:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a95:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801a98:	83 ec 0c             	sub    $0xc,%esp
  801a9b:	50                   	push   %eax
  801a9c:	e8 72 e8 ff ff       	call   800313 <sys_ipc_recv>
  801aa1:	89 c7                	mov    %eax,%edi
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	79 14                	jns    801abe <ipc_recv+0x56>
		cprintf("im dead");
  801aaa:	83 ec 0c             	sub    $0xc,%esp
  801aad:	68 a0 22 80 00       	push   $0x8022a0
  801ab2:	e8 66 f6 ff ff       	call   80111d <cprintf>
		return r;
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	89 f8                	mov    %edi,%eax
  801abc:	eb 24                	jmp    801ae2 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801abe:	85 f6                	test   %esi,%esi
  801ac0:	74 0a                	je     801acc <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801ac2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac7:	8b 40 74             	mov    0x74(%eax),%eax
  801aca:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801acc:	85 db                	test   %ebx,%ebx
  801ace:	74 0a                	je     801ada <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801ad0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad5:	8b 40 78             	mov    0x78(%eax),%eax
  801ad8:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801ada:	a1 04 40 80 00       	mov    0x804004,%eax
  801adf:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ae2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae5:	5b                   	pop    %ebx
  801ae6:	5e                   	pop    %esi
  801ae7:	5f                   	pop    %edi
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	57                   	push   %edi
  801aee:	56                   	push   %esi
  801aef:	53                   	push   %ebx
  801af0:	83 ec 0c             	sub    $0xc,%esp
  801af3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801af6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801afc:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801afe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b03:	0f 44 d8             	cmove  %eax,%ebx
  801b06:	eb 1c                	jmp    801b24 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801b08:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b0b:	74 12                	je     801b1f <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801b0d:	50                   	push   %eax
  801b0e:	68 a8 22 80 00       	push   $0x8022a8
  801b13:	6a 4e                	push   $0x4e
  801b15:	68 b5 22 80 00       	push   $0x8022b5
  801b1a:	e8 25 f5 ff ff       	call   801044 <_panic>
		sys_yield();
  801b1f:	e8 20 e6 ff ff       	call   800144 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b24:	ff 75 14             	pushl  0x14(%ebp)
  801b27:	53                   	push   %ebx
  801b28:	56                   	push   %esi
  801b29:	57                   	push   %edi
  801b2a:	e8 c1 e7 ff ff       	call   8002f0 <sys_ipc_try_send>
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	85 c0                	test   %eax,%eax
  801b34:	78 d2                	js     801b08 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5f                   	pop    %edi
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b49:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b4c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b52:	8b 52 50             	mov    0x50(%edx),%edx
  801b55:	39 ca                	cmp    %ecx,%edx
  801b57:	75 0d                	jne    801b66 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b59:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b5c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b61:	8b 40 48             	mov    0x48(%eax),%eax
  801b64:	eb 0f                	jmp    801b75 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b66:	83 c0 01             	add    $0x1,%eax
  801b69:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b6e:	75 d9                	jne    801b49 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    

00801b77 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b7d:	89 d0                	mov    %edx,%eax
  801b7f:	c1 e8 16             	shr    $0x16,%eax
  801b82:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8e:	f6 c1 01             	test   $0x1,%cl
  801b91:	74 1d                	je     801bb0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b93:	c1 ea 0c             	shr    $0xc,%edx
  801b96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b9d:	f6 c2 01             	test   $0x1,%dl
  801ba0:	74 0e                	je     801bb0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba2:	c1 ea 0c             	shr    $0xc,%edx
  801ba5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bac:	ef 
  801bad:	0f b7 c0             	movzwl %ax,%eax
}
  801bb0:	5d                   	pop    %ebp
  801bb1:	c3                   	ret    
  801bb2:	66 90                	xchg   %ax,%ax
  801bb4:	66 90                	xchg   %ax,%ax
  801bb6:	66 90                	xchg   %ax,%ax
  801bb8:	66 90                	xchg   %ax,%ax
  801bba:	66 90                	xchg   %ax,%ax
  801bbc:	66 90                	xchg   %ax,%ax
  801bbe:	66 90                	xchg   %ax,%ax

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
