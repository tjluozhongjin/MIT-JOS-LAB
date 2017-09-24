
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 ad 00 00 00       	call   8000de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	68 e0 1e 80 00       	push   $0x801ee0
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 c3 01 00 00       	call   800221 <strcmp>
  80005e:	83 c4 10             	add    $0x10,%esp
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 38                	jmp    8000b8 <umain+0x85>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 14                	jle    800099 <umain+0x66>
			write(1, " ", 1);
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 01                	push   $0x1
  80008a:	68 e3 1e 80 00       	push   $0x801ee3
  80008f:	6a 01                	push   $0x1
  800091:	e8 8b 0a 00 00       	call   800b21 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 9a 00 00 00       	call   80013e <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 6f 0a 00 00       	call   800b21 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b2:	83 c3 01             	add    $0x1,%ebx
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	39 df                	cmp    %ebx,%edi
  8000ba:	7f c4                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	75 14                	jne    8000d6 <umain+0xa3>
		write(1, "\n", 1);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	6a 01                	push   $0x1
  8000c7:	68 f3 1f 80 00       	push   $0x801ff3
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 4e 0a 00 00       	call   800b21 <write>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e9:	e8 4e 04 00 00       	call   80053c <sys_getenvid>
  8000ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fb:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800100:	85 db                	test   %ebx,%ebx
  800102:	7e 07                	jle    80010b <libmain+0x2d>
		binaryname = argv[0];
  800104:	8b 06                	mov    (%esi),%eax
  800106:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	e8 1e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800115:	e8 0a 00 00 00       	call   800124 <exit>
}
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012a:	e8 07 08 00 00       	call   800936 <close_all>
	sys_env_destroy(0);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	6a 00                	push   $0x0
  800134:	e8 c2 03 00 00       	call   8004fb <sys_env_destroy>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800144:	b8 00 00 00 00       	mov    $0x0,%eax
  800149:	eb 03                	jmp    80014e <strlen+0x10>
		n++;
  80014b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80014e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800152:	75 f7                	jne    80014b <strlen+0xd>
		n++;
	return n;
}
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	eb 03                	jmp    800169 <strnlen+0x13>
		n++;
  800166:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800169:	39 c2                	cmp    %eax,%edx
  80016b:	74 08                	je     800175 <strnlen+0x1f>
  80016d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800171:	75 f3                	jne    800166 <strnlen+0x10>
  800173:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800181:	89 c2                	mov    %eax,%edx
  800183:	83 c2 01             	add    $0x1,%edx
  800186:	83 c1 01             	add    $0x1,%ecx
  800189:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80018d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800190:	84 db                	test   %bl,%bl
  800192:	75 ef                	jne    800183 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800194:	5b                   	pop    %ebx
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80019e:	53                   	push   %ebx
  80019f:	e8 9a ff ff ff       	call   80013e <strlen>
  8001a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001a7:	ff 75 0c             	pushl  0xc(%ebp)
  8001aa:	01 d8                	add    %ebx,%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 c5 ff ff ff       	call   800177 <strcpy>
	return dst;
}
  8001b2:	89 d8                	mov    %ebx,%eax
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	89 f3                	mov    %esi,%ebx
  8001c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001c9:	89 f2                	mov    %esi,%edx
  8001cb:	eb 0f                	jmp    8001dc <strncpy+0x23>
		*dst++ = *src;
  8001cd:	83 c2 01             	add    $0x1,%edx
  8001d0:	0f b6 01             	movzbl (%ecx),%eax
  8001d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8001d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001dc:	39 da                	cmp    %ebx,%edx
  8001de:	75 ed                	jne    8001cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001e0:	89 f0                	mov    %esi,%eax
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8001f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001f6:	85 d2                	test   %edx,%edx
  8001f8:	74 21                	je     80021b <strlcpy+0x35>
  8001fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	eb 09                	jmp    80020b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800202:	83 c2 01             	add    $0x1,%edx
  800205:	83 c1 01             	add    $0x1,%ecx
  800208:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80020b:	39 c2                	cmp    %eax,%edx
  80020d:	74 09                	je     800218 <strlcpy+0x32>
  80020f:	0f b6 19             	movzbl (%ecx),%ebx
  800212:	84 db                	test   %bl,%bl
  800214:	75 ec                	jne    800202 <strlcpy+0x1c>
  800216:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800218:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80021b:	29 f0                	sub    %esi,%eax
}
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80022a:	eb 06                	jmp    800232 <strcmp+0x11>
		p++, q++;
  80022c:	83 c1 01             	add    $0x1,%ecx
  80022f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800232:	0f b6 01             	movzbl (%ecx),%eax
  800235:	84 c0                	test   %al,%al
  800237:	74 04                	je     80023d <strcmp+0x1c>
  800239:	3a 02                	cmp    (%edx),%al
  80023b:	74 ef                	je     80022c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80023d:	0f b6 c0             	movzbl %al,%eax
  800240:	0f b6 12             	movzbl (%edx),%edx
  800243:	29 d0                	sub    %edx,%eax
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	53                   	push   %ebx
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800251:	89 c3                	mov    %eax,%ebx
  800253:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800256:	eb 06                	jmp    80025e <strncmp+0x17>
		n--, p++, q++;
  800258:	83 c0 01             	add    $0x1,%eax
  80025b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80025e:	39 d8                	cmp    %ebx,%eax
  800260:	74 15                	je     800277 <strncmp+0x30>
  800262:	0f b6 08             	movzbl (%eax),%ecx
  800265:	84 c9                	test   %cl,%cl
  800267:	74 04                	je     80026d <strncmp+0x26>
  800269:	3a 0a                	cmp    (%edx),%cl
  80026b:	74 eb                	je     800258 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80026d:	0f b6 00             	movzbl (%eax),%eax
  800270:	0f b6 12             	movzbl (%edx),%edx
  800273:	29 d0                	sub    %edx,%eax
  800275:	eb 05                	jmp    80027c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800277:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80027c:	5b                   	pop    %ebx
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800289:	eb 07                	jmp    800292 <strchr+0x13>
		if (*s == c)
  80028b:	38 ca                	cmp    %cl,%dl
  80028d:	74 0f                	je     80029e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80028f:	83 c0 01             	add    $0x1,%eax
  800292:	0f b6 10             	movzbl (%eax),%edx
  800295:	84 d2                	test   %dl,%dl
  800297:	75 f2                	jne    80028b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002aa:	eb 03                	jmp    8002af <strfind+0xf>
  8002ac:	83 c0 01             	add    $0x1,%eax
  8002af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002b2:	38 ca                	cmp    %cl,%dl
  8002b4:	74 04                	je     8002ba <strfind+0x1a>
  8002b6:	84 d2                	test   %dl,%dl
  8002b8:	75 f2                	jne    8002ac <strfind+0xc>
			break;
	return (char *) s;
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002c8:	85 c9                	test   %ecx,%ecx
  8002ca:	74 36                	je     800302 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002d2:	75 28                	jne    8002fc <memset+0x40>
  8002d4:	f6 c1 03             	test   $0x3,%cl
  8002d7:	75 23                	jne    8002fc <memset+0x40>
		c &= 0xFF;
  8002d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002dd:	89 d3                	mov    %edx,%ebx
  8002df:	c1 e3 08             	shl    $0x8,%ebx
  8002e2:	89 d6                	mov    %edx,%esi
  8002e4:	c1 e6 18             	shl    $0x18,%esi
  8002e7:	89 d0                	mov    %edx,%eax
  8002e9:	c1 e0 10             	shl    $0x10,%eax
  8002ec:	09 f0                	or     %esi,%eax
  8002ee:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8002f0:	89 d8                	mov    %ebx,%eax
  8002f2:	09 d0                	or     %edx,%eax
  8002f4:	c1 e9 02             	shr    $0x2,%ecx
  8002f7:	fc                   	cld    
  8002f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8002fa:	eb 06                	jmp    800302 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	fc                   	cld    
  800300:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800302:	89 f8                	mov    %edi,%eax
  800304:	5b                   	pop    %ebx
  800305:	5e                   	pop    %esi
  800306:	5f                   	pop    %edi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 75 0c             	mov    0xc(%ebp),%esi
  800314:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800317:	39 c6                	cmp    %eax,%esi
  800319:	73 35                	jae    800350 <memmove+0x47>
  80031b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80031e:	39 d0                	cmp    %edx,%eax
  800320:	73 2e                	jae    800350 <memmove+0x47>
		s += n;
		d += n;
  800322:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800325:	89 d6                	mov    %edx,%esi
  800327:	09 fe                	or     %edi,%esi
  800329:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80032f:	75 13                	jne    800344 <memmove+0x3b>
  800331:	f6 c1 03             	test   $0x3,%cl
  800334:	75 0e                	jne    800344 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800336:	83 ef 04             	sub    $0x4,%edi
  800339:	8d 72 fc             	lea    -0x4(%edx),%esi
  80033c:	c1 e9 02             	shr    $0x2,%ecx
  80033f:	fd                   	std    
  800340:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800342:	eb 09                	jmp    80034d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800344:	83 ef 01             	sub    $0x1,%edi
  800347:	8d 72 ff             	lea    -0x1(%edx),%esi
  80034a:	fd                   	std    
  80034b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80034d:	fc                   	cld    
  80034e:	eb 1d                	jmp    80036d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800350:	89 f2                	mov    %esi,%edx
  800352:	09 c2                	or     %eax,%edx
  800354:	f6 c2 03             	test   $0x3,%dl
  800357:	75 0f                	jne    800368 <memmove+0x5f>
  800359:	f6 c1 03             	test   $0x3,%cl
  80035c:	75 0a                	jne    800368 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80035e:	c1 e9 02             	shr    $0x2,%ecx
  800361:	89 c7                	mov    %eax,%edi
  800363:	fc                   	cld    
  800364:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800366:	eb 05                	jmp    80036d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800368:	89 c7                	mov    %eax,%edi
  80036a:	fc                   	cld    
  80036b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 87 ff ff ff       	call   800309 <memmove>
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	89 c6                	mov    %eax,%esi
  800391:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800394:	eb 1a                	jmp    8003b0 <memcmp+0x2c>
		if (*s1 != *s2)
  800396:	0f b6 08             	movzbl (%eax),%ecx
  800399:	0f b6 1a             	movzbl (%edx),%ebx
  80039c:	38 d9                	cmp    %bl,%cl
  80039e:	74 0a                	je     8003aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003a0:	0f b6 c1             	movzbl %cl,%eax
  8003a3:	0f b6 db             	movzbl %bl,%ebx
  8003a6:	29 d8                	sub    %ebx,%eax
  8003a8:	eb 0f                	jmp    8003b9 <memcmp+0x35>
		s1++, s2++;
  8003aa:	83 c0 01             	add    $0x1,%eax
  8003ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003b0:	39 f0                	cmp    %esi,%eax
  8003b2:	75 e2                	jne    800396 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	53                   	push   %ebx
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8003c4:	89 c1                	mov    %eax,%ecx
  8003c6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8003c9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003cd:	eb 0a                	jmp    8003d9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003cf:	0f b6 10             	movzbl (%eax),%edx
  8003d2:	39 da                	cmp    %ebx,%edx
  8003d4:	74 07                	je     8003dd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003d6:	83 c0 01             	add    $0x1,%eax
  8003d9:	39 c8                	cmp    %ecx,%eax
  8003db:	72 f2                	jb     8003cf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003dd:	5b                   	pop    %ebx
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	57                   	push   %edi
  8003e4:	56                   	push   %esi
  8003e5:	53                   	push   %ebx
  8003e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003ec:	eb 03                	jmp    8003f1 <strtol+0x11>
		s++;
  8003ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003f1:	0f b6 01             	movzbl (%ecx),%eax
  8003f4:	3c 20                	cmp    $0x20,%al
  8003f6:	74 f6                	je     8003ee <strtol+0xe>
  8003f8:	3c 09                	cmp    $0x9,%al
  8003fa:	74 f2                	je     8003ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8003fc:	3c 2b                	cmp    $0x2b,%al
  8003fe:	75 0a                	jne    80040a <strtol+0x2a>
		s++;
  800400:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800403:	bf 00 00 00 00       	mov    $0x0,%edi
  800408:	eb 11                	jmp    80041b <strtol+0x3b>
  80040a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80040f:	3c 2d                	cmp    $0x2d,%al
  800411:	75 08                	jne    80041b <strtol+0x3b>
		s++, neg = 1;
  800413:	83 c1 01             	add    $0x1,%ecx
  800416:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80041b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800421:	75 15                	jne    800438 <strtol+0x58>
  800423:	80 39 30             	cmpb   $0x30,(%ecx)
  800426:	75 10                	jne    800438 <strtol+0x58>
  800428:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80042c:	75 7c                	jne    8004aa <strtol+0xca>
		s += 2, base = 16;
  80042e:	83 c1 02             	add    $0x2,%ecx
  800431:	bb 10 00 00 00       	mov    $0x10,%ebx
  800436:	eb 16                	jmp    80044e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800438:	85 db                	test   %ebx,%ebx
  80043a:	75 12                	jne    80044e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80043c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800441:	80 39 30             	cmpb   $0x30,(%ecx)
  800444:	75 08                	jne    80044e <strtol+0x6e>
		s++, base = 8;
  800446:	83 c1 01             	add    $0x1,%ecx
  800449:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800456:	0f b6 11             	movzbl (%ecx),%edx
  800459:	8d 72 d0             	lea    -0x30(%edx),%esi
  80045c:	89 f3                	mov    %esi,%ebx
  80045e:	80 fb 09             	cmp    $0x9,%bl
  800461:	77 08                	ja     80046b <strtol+0x8b>
			dig = *s - '0';
  800463:	0f be d2             	movsbl %dl,%edx
  800466:	83 ea 30             	sub    $0x30,%edx
  800469:	eb 22                	jmp    80048d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80046b:	8d 72 9f             	lea    -0x61(%edx),%esi
  80046e:	89 f3                	mov    %esi,%ebx
  800470:	80 fb 19             	cmp    $0x19,%bl
  800473:	77 08                	ja     80047d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800475:	0f be d2             	movsbl %dl,%edx
  800478:	83 ea 57             	sub    $0x57,%edx
  80047b:	eb 10                	jmp    80048d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80047d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800480:	89 f3                	mov    %esi,%ebx
  800482:	80 fb 19             	cmp    $0x19,%bl
  800485:	77 16                	ja     80049d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800487:	0f be d2             	movsbl %dl,%edx
  80048a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80048d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800490:	7d 0b                	jge    80049d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800492:	83 c1 01             	add    $0x1,%ecx
  800495:	0f af 45 10          	imul   0x10(%ebp),%eax
  800499:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80049b:	eb b9                	jmp    800456 <strtol+0x76>

	if (endptr)
  80049d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004a1:	74 0d                	je     8004b0 <strtol+0xd0>
		*endptr = (char *) s;
  8004a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004a6:	89 0e                	mov    %ecx,(%esi)
  8004a8:	eb 06                	jmp    8004b0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004aa:	85 db                	test   %ebx,%ebx
  8004ac:	74 98                	je     800446 <strtol+0x66>
  8004ae:	eb 9e                	jmp    80044e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8004b0:	89 c2                	mov    %eax,%edx
  8004b2:	f7 da                	neg    %edx
  8004b4:	85 ff                	test   %edi,%edi
  8004b6:	0f 45 c2             	cmovne %edx,%eax
}
  8004b9:	5b                   	pop    %ebx
  8004ba:	5e                   	pop    %esi
  8004bb:	5f                   	pop    %edi
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	57                   	push   %edi
  8004c2:	56                   	push   %esi
  8004c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	89 c7                	mov    %eax,%edi
  8004d3:	89 c6                	mov    %eax,%esi
  8004d5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004d7:	5b                   	pop    %ebx
  8004d8:	5e                   	pop    %esi
  8004d9:	5f                   	pop    %edi
  8004da:	5d                   	pop    %ebp
  8004db:	c3                   	ret    

008004dc <sys_cgetc>:

int
sys_cgetc(void)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8004ec:	89 d1                	mov    %edx,%ecx
  8004ee:	89 d3                	mov    %edx,%ebx
  8004f0:	89 d7                	mov    %edx,%edi
  8004f2:	89 d6                	mov    %edx,%esi
  8004f4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004f6:	5b                   	pop    %ebx
  8004f7:	5e                   	pop    %esi
  8004f8:	5f                   	pop    %edi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	57                   	push   %edi
  8004ff:	56                   	push   %esi
  800500:	53                   	push   %ebx
  800501:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800504:	b9 00 00 00 00       	mov    $0x0,%ecx
  800509:	b8 03 00 00 00       	mov    $0x3,%eax
  80050e:	8b 55 08             	mov    0x8(%ebp),%edx
  800511:	89 cb                	mov    %ecx,%ebx
  800513:	89 cf                	mov    %ecx,%edi
  800515:	89 ce                	mov    %ecx,%esi
  800517:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800519:	85 c0                	test   %eax,%eax
  80051b:	7e 17                	jle    800534 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	50                   	push   %eax
  800521:	6a 03                	push   $0x3
  800523:	68 ef 1e 80 00       	push   $0x801eef
  800528:	6a 23                	push   $0x23
  80052a:	68 0c 1f 80 00       	push   $0x801f0c
  80052f:	e8 27 0f 00 00       	call   80145b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800534:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800537:	5b                   	pop    %ebx
  800538:	5e                   	pop    %esi
  800539:	5f                   	pop    %edi
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    

0080053c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	57                   	push   %edi
  800540:	56                   	push   %esi
  800541:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800542:	ba 00 00 00 00       	mov    $0x0,%edx
  800547:	b8 02 00 00 00       	mov    $0x2,%eax
  80054c:	89 d1                	mov    %edx,%ecx
  80054e:	89 d3                	mov    %edx,%ebx
  800550:	89 d7                	mov    %edx,%edi
  800552:	89 d6                	mov    %edx,%esi
  800554:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800556:	5b                   	pop    %ebx
  800557:	5e                   	pop    %esi
  800558:	5f                   	pop    %edi
  800559:	5d                   	pop    %ebp
  80055a:	c3                   	ret    

0080055b <sys_yield>:

void
sys_yield(void)
{
  80055b:	55                   	push   %ebp
  80055c:	89 e5                	mov    %esp,%ebp
  80055e:	57                   	push   %edi
  80055f:	56                   	push   %esi
  800560:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800561:	ba 00 00 00 00       	mov    $0x0,%edx
  800566:	b8 0b 00 00 00       	mov    $0xb,%eax
  80056b:	89 d1                	mov    %edx,%ecx
  80056d:	89 d3                	mov    %edx,%ebx
  80056f:	89 d7                	mov    %edx,%edi
  800571:	89 d6                	mov    %edx,%esi
  800573:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800575:	5b                   	pop    %ebx
  800576:	5e                   	pop    %esi
  800577:	5f                   	pop    %edi
  800578:	5d                   	pop    %ebp
  800579:	c3                   	ret    

0080057a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	57                   	push   %edi
  80057e:	56                   	push   %esi
  80057f:	53                   	push   %ebx
  800580:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800583:	be 00 00 00 00       	mov    $0x0,%esi
  800588:	b8 04 00 00 00       	mov    $0x4,%eax
  80058d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800590:	8b 55 08             	mov    0x8(%ebp),%edx
  800593:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800596:	89 f7                	mov    %esi,%edi
  800598:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80059a:	85 c0                	test   %eax,%eax
  80059c:	7e 17                	jle    8005b5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80059e:	83 ec 0c             	sub    $0xc,%esp
  8005a1:	50                   	push   %eax
  8005a2:	6a 04                	push   $0x4
  8005a4:	68 ef 1e 80 00       	push   $0x801eef
  8005a9:	6a 23                	push   $0x23
  8005ab:	68 0c 1f 80 00       	push   $0x801f0c
  8005b0:	e8 a6 0e 00 00       	call   80145b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b8:	5b                   	pop    %ebx
  8005b9:	5e                   	pop    %esi
  8005ba:	5f                   	pop    %edi
  8005bb:	5d                   	pop    %ebp
  8005bc:	c3                   	ret    

008005bd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	57                   	push   %edi
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8005cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005d4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8005da:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	7e 17                	jle    8005f7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	50                   	push   %eax
  8005e4:	6a 05                	push   $0x5
  8005e6:	68 ef 1e 80 00       	push   $0x801eef
  8005eb:	6a 23                	push   $0x23
  8005ed:	68 0c 1f 80 00       	push   $0x801f0c
  8005f2:	e8 64 0e 00 00       	call   80145b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fa:	5b                   	pop    %ebx
  8005fb:	5e                   	pop    %esi
  8005fc:	5f                   	pop    %edi
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    

008005ff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005ff:	55                   	push   %ebp
  800600:	89 e5                	mov    %esp,%ebp
  800602:	57                   	push   %edi
  800603:	56                   	push   %esi
  800604:	53                   	push   %ebx
  800605:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800608:	bb 00 00 00 00       	mov    $0x0,%ebx
  80060d:	b8 06 00 00 00       	mov    $0x6,%eax
  800612:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800615:	8b 55 08             	mov    0x8(%ebp),%edx
  800618:	89 df                	mov    %ebx,%edi
  80061a:	89 de                	mov    %ebx,%esi
  80061c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80061e:	85 c0                	test   %eax,%eax
  800620:	7e 17                	jle    800639 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800622:	83 ec 0c             	sub    $0xc,%esp
  800625:	50                   	push   %eax
  800626:	6a 06                	push   $0x6
  800628:	68 ef 1e 80 00       	push   $0x801eef
  80062d:	6a 23                	push   $0x23
  80062f:	68 0c 1f 80 00       	push   $0x801f0c
  800634:	e8 22 0e 00 00       	call   80145b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5e                   	pop    %esi
  80063e:	5f                   	pop    %edi
  80063f:	5d                   	pop    %ebp
  800640:	c3                   	ret    

00800641 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	57                   	push   %edi
  800645:	56                   	push   %esi
  800646:	53                   	push   %ebx
  800647:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80064a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
  800654:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800657:	8b 55 08             	mov    0x8(%ebp),%edx
  80065a:	89 df                	mov    %ebx,%edi
  80065c:	89 de                	mov    %ebx,%esi
  80065e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800660:	85 c0                	test   %eax,%eax
  800662:	7e 17                	jle    80067b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800664:	83 ec 0c             	sub    $0xc,%esp
  800667:	50                   	push   %eax
  800668:	6a 08                	push   $0x8
  80066a:	68 ef 1e 80 00       	push   $0x801eef
  80066f:	6a 23                	push   $0x23
  800671:	68 0c 1f 80 00       	push   $0x801f0c
  800676:	e8 e0 0d 00 00       	call   80145b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80067b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067e:	5b                   	pop    %ebx
  80067f:	5e                   	pop    %esi
  800680:	5f                   	pop    %edi
  800681:	5d                   	pop    %ebp
  800682:	c3                   	ret    

00800683 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	57                   	push   %edi
  800687:	56                   	push   %esi
  800688:	53                   	push   %ebx
  800689:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80068c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800691:	b8 09 00 00 00       	mov    $0x9,%eax
  800696:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800699:	8b 55 08             	mov    0x8(%ebp),%edx
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	89 de                	mov    %ebx,%esi
  8006a0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006a2:	85 c0                	test   %eax,%eax
  8006a4:	7e 17                	jle    8006bd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a6:	83 ec 0c             	sub    $0xc,%esp
  8006a9:	50                   	push   %eax
  8006aa:	6a 09                	push   $0x9
  8006ac:	68 ef 1e 80 00       	push   $0x801eef
  8006b1:	6a 23                	push   $0x23
  8006b3:	68 0c 1f 80 00       	push   $0x801f0c
  8006b8:	e8 9e 0d 00 00       	call   80145b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c0:	5b                   	pop    %ebx
  8006c1:	5e                   	pop    %esi
  8006c2:	5f                   	pop    %edi
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	57                   	push   %edi
  8006c9:	56                   	push   %esi
  8006ca:	53                   	push   %ebx
  8006cb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
  8006de:	89 df                	mov    %ebx,%edi
  8006e0:	89 de                	mov    %ebx,%esi
  8006e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	7e 17                	jle    8006ff <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006e8:	83 ec 0c             	sub    $0xc,%esp
  8006eb:	50                   	push   %eax
  8006ec:	6a 0a                	push   $0xa
  8006ee:	68 ef 1e 80 00       	push   $0x801eef
  8006f3:	6a 23                	push   $0x23
  8006f5:	68 0c 1f 80 00       	push   $0x801f0c
  8006fa:	e8 5c 0d 00 00       	call   80145b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	5f                   	pop    %edi
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	57                   	push   %edi
  80070b:	56                   	push   %esi
  80070c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80070d:	be 00 00 00 00       	mov    $0x0,%esi
  800712:	b8 0c 00 00 00       	mov    $0xc,%eax
  800717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071a:	8b 55 08             	mov    0x8(%ebp),%edx
  80071d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800720:	8b 7d 14             	mov    0x14(%ebp),%edi
  800723:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800725:	5b                   	pop    %ebx
  800726:	5e                   	pop    %esi
  800727:	5f                   	pop    %edi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	57                   	push   %edi
  80072e:	56                   	push   %esi
  80072f:	53                   	push   %ebx
  800730:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800733:	b9 00 00 00 00       	mov    $0x0,%ecx
  800738:	b8 0d 00 00 00       	mov    $0xd,%eax
  80073d:	8b 55 08             	mov    0x8(%ebp),%edx
  800740:	89 cb                	mov    %ecx,%ebx
  800742:	89 cf                	mov    %ecx,%edi
  800744:	89 ce                	mov    %ecx,%esi
  800746:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800748:	85 c0                	test   %eax,%eax
  80074a:	7e 17                	jle    800763 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80074c:	83 ec 0c             	sub    $0xc,%esp
  80074f:	50                   	push   %eax
  800750:	6a 0d                	push   $0xd
  800752:	68 ef 1e 80 00       	push   $0x801eef
  800757:	6a 23                	push   $0x23
  800759:	68 0c 1f 80 00       	push   $0x801f0c
  80075e:	e8 f8 0c 00 00       	call   80145b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800763:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5f                   	pop    %edi
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	05 00 00 00 30       	add    $0x30000000,%eax
  800776:	c1 e8 0c             	shr    $0xc,%eax
}
  800779:	5d                   	pop    %ebp
  80077a:	c3                   	ret    

0080077b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	05 00 00 00 30       	add    $0x30000000,%eax
  800786:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80078b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800798:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	c1 ea 16             	shr    $0x16,%edx
  8007a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007a9:	f6 c2 01             	test   $0x1,%dl
  8007ac:	74 11                	je     8007bf <fd_alloc+0x2d>
  8007ae:	89 c2                	mov    %eax,%edx
  8007b0:	c1 ea 0c             	shr    $0xc,%edx
  8007b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007ba:	f6 c2 01             	test   $0x1,%dl
  8007bd:	75 09                	jne    8007c8 <fd_alloc+0x36>
			*fd_store = fd;
  8007bf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c6:	eb 17                	jmp    8007df <fd_alloc+0x4d>
  8007c8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8007cd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007d2:	75 c9                	jne    80079d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8007d4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8007da:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8007e7:	83 f8 1f             	cmp    $0x1f,%eax
  8007ea:	77 36                	ja     800822 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8007ec:	c1 e0 0c             	shl    $0xc,%eax
  8007ef:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	c1 ea 16             	shr    $0x16,%edx
  8007f9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800800:	f6 c2 01             	test   $0x1,%dl
  800803:	74 24                	je     800829 <fd_lookup+0x48>
  800805:	89 c2                	mov    %eax,%edx
  800807:	c1 ea 0c             	shr    $0xc,%edx
  80080a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800811:	f6 c2 01             	test   $0x1,%dl
  800814:	74 1a                	je     800830 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
  800819:	89 02                	mov    %eax,(%edx)
	return 0;
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
  800820:	eb 13                	jmp    800835 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800827:	eb 0c                	jmp    800835 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800829:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082e:	eb 05                	jmp    800835 <fd_lookup+0x54>
  800830:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800840:	ba 98 1f 80 00       	mov    $0x801f98,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800845:	eb 13                	jmp    80085a <dev_lookup+0x23>
  800847:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80084a:	39 08                	cmp    %ecx,(%eax)
  80084c:	75 0c                	jne    80085a <dev_lookup+0x23>
			*dev = devtab[i];
  80084e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800851:	89 01                	mov    %eax,(%ecx)
			return 0;
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	eb 2e                	jmp    800888 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80085a:	8b 02                	mov    (%edx),%eax
  80085c:	85 c0                	test   %eax,%eax
  80085e:	75 e7                	jne    800847 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800860:	a1 04 40 80 00       	mov    0x804004,%eax
  800865:	8b 40 48             	mov    0x48(%eax),%eax
  800868:	83 ec 04             	sub    $0x4,%esp
  80086b:	51                   	push   %ecx
  80086c:	50                   	push   %eax
  80086d:	68 1c 1f 80 00       	push   $0x801f1c
  800872:	e8 bd 0c 00 00       	call   801534 <cprintf>
	*dev = 0;
  800877:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800880:	83 c4 10             	add    $0x10,%esp
  800883:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
  80088f:	83 ec 10             	sub    $0x10,%esp
  800892:	8b 75 08             	mov    0x8(%ebp),%esi
  800895:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800898:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089b:	50                   	push   %eax
  80089c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8008a2:	c1 e8 0c             	shr    $0xc,%eax
  8008a5:	50                   	push   %eax
  8008a6:	e8 36 ff ff ff       	call   8007e1 <fd_lookup>
  8008ab:	83 c4 08             	add    $0x8,%esp
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 05                	js     8008b7 <fd_close+0x2d>
	    || fd != fd2)
  8008b2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008b5:	74 0c                	je     8008c3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8008b7:	84 db                	test   %bl,%bl
  8008b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008be:	0f 44 c2             	cmove  %edx,%eax
  8008c1:	eb 41                	jmp    800904 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008c9:	50                   	push   %eax
  8008ca:	ff 36                	pushl  (%esi)
  8008cc:	e8 66 ff ff ff       	call   800837 <dev_lookup>
  8008d1:	89 c3                	mov    %eax,%ebx
  8008d3:	83 c4 10             	add    $0x10,%esp
  8008d6:	85 c0                	test   %eax,%eax
  8008d8:	78 1a                	js     8008f4 <fd_close+0x6a>
		if (dev->dev_close)
  8008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008dd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8008e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8008e5:	85 c0                	test   %eax,%eax
  8008e7:	74 0b                	je     8008f4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8008e9:	83 ec 0c             	sub    $0xc,%esp
  8008ec:	56                   	push   %esi
  8008ed:	ff d0                	call   *%eax
  8008ef:	89 c3                	mov    %eax,%ebx
  8008f1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8008f4:	83 ec 08             	sub    $0x8,%esp
  8008f7:	56                   	push   %esi
  8008f8:	6a 00                	push   $0x0
  8008fa:	e8 00 fd ff ff       	call   8005ff <sys_page_unmap>
	return r;
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	89 d8                	mov    %ebx,%eax
}
  800904:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800911:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800914:	50                   	push   %eax
  800915:	ff 75 08             	pushl  0x8(%ebp)
  800918:	e8 c4 fe ff ff       	call   8007e1 <fd_lookup>
  80091d:	83 c4 08             	add    $0x8,%esp
  800920:	85 c0                	test   %eax,%eax
  800922:	78 10                	js     800934 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800924:	83 ec 08             	sub    $0x8,%esp
  800927:	6a 01                	push   $0x1
  800929:	ff 75 f4             	pushl  -0xc(%ebp)
  80092c:	e8 59 ff ff ff       	call   80088a <fd_close>
  800931:	83 c4 10             	add    $0x10,%esp
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <close_all>:

void
close_all(void)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	53                   	push   %ebx
  80093a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80093d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800942:	83 ec 0c             	sub    $0xc,%esp
  800945:	53                   	push   %ebx
  800946:	e8 c0 ff ff ff       	call   80090b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80094b:	83 c3 01             	add    $0x1,%ebx
  80094e:	83 c4 10             	add    $0x10,%esp
  800951:	83 fb 20             	cmp    $0x20,%ebx
  800954:	75 ec                	jne    800942 <close_all+0xc>
		close(i);
}
  800956:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	57                   	push   %edi
  80095f:	56                   	push   %esi
  800960:	53                   	push   %ebx
  800961:	83 ec 2c             	sub    $0x2c,%esp
  800964:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800967:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80096a:	50                   	push   %eax
  80096b:	ff 75 08             	pushl  0x8(%ebp)
  80096e:	e8 6e fe ff ff       	call   8007e1 <fd_lookup>
  800973:	83 c4 08             	add    $0x8,%esp
  800976:	85 c0                	test   %eax,%eax
  800978:	0f 88 c1 00 00 00    	js     800a3f <dup+0xe4>
		return r;
	close(newfdnum);
  80097e:	83 ec 0c             	sub    $0xc,%esp
  800981:	56                   	push   %esi
  800982:	e8 84 ff ff ff       	call   80090b <close>

	newfd = INDEX2FD(newfdnum);
  800987:	89 f3                	mov    %esi,%ebx
  800989:	c1 e3 0c             	shl    $0xc,%ebx
  80098c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800992:	83 c4 04             	add    $0x4,%esp
  800995:	ff 75 e4             	pushl  -0x1c(%ebp)
  800998:	e8 de fd ff ff       	call   80077b <fd2data>
  80099d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80099f:	89 1c 24             	mov    %ebx,(%esp)
  8009a2:	e8 d4 fd ff ff       	call   80077b <fd2data>
  8009a7:	83 c4 10             	add    $0x10,%esp
  8009aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009ad:	89 f8                	mov    %edi,%eax
  8009af:	c1 e8 16             	shr    $0x16,%eax
  8009b2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009b9:	a8 01                	test   $0x1,%al
  8009bb:	74 37                	je     8009f4 <dup+0x99>
  8009bd:	89 f8                	mov    %edi,%eax
  8009bf:	c1 e8 0c             	shr    $0xc,%eax
  8009c2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009c9:	f6 c2 01             	test   $0x1,%dl
  8009cc:	74 26                	je     8009f4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8009ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009d5:	83 ec 0c             	sub    $0xc,%esp
  8009d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8009dd:	50                   	push   %eax
  8009de:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009e1:	6a 00                	push   $0x0
  8009e3:	57                   	push   %edi
  8009e4:	6a 00                	push   $0x0
  8009e6:	e8 d2 fb ff ff       	call   8005bd <sys_page_map>
  8009eb:	89 c7                	mov    %eax,%edi
  8009ed:	83 c4 20             	add    $0x20,%esp
  8009f0:	85 c0                	test   %eax,%eax
  8009f2:	78 2e                	js     800a22 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009f7:	89 d0                	mov    %edx,%eax
  8009f9:	c1 e8 0c             	shr    $0xc,%eax
  8009fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a03:	83 ec 0c             	sub    $0xc,%esp
  800a06:	25 07 0e 00 00       	and    $0xe07,%eax
  800a0b:	50                   	push   %eax
  800a0c:	53                   	push   %ebx
  800a0d:	6a 00                	push   $0x0
  800a0f:	52                   	push   %edx
  800a10:	6a 00                	push   $0x0
  800a12:	e8 a6 fb ff ff       	call   8005bd <sys_page_map>
  800a17:	89 c7                	mov    %eax,%edi
  800a19:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800a1c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a1e:	85 ff                	test   %edi,%edi
  800a20:	79 1d                	jns    800a3f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a22:	83 ec 08             	sub    $0x8,%esp
  800a25:	53                   	push   %ebx
  800a26:	6a 00                	push   $0x0
  800a28:	e8 d2 fb ff ff       	call   8005ff <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a2d:	83 c4 08             	add    $0x8,%esp
  800a30:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a33:	6a 00                	push   $0x0
  800a35:	e8 c5 fb ff ff       	call   8005ff <sys_page_unmap>
	return r;
  800a3a:	83 c4 10             	add    $0x10,%esp
  800a3d:	89 f8                	mov    %edi,%eax
}
  800a3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	53                   	push   %ebx
  800a4b:	83 ec 14             	sub    $0x14,%esp
  800a4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a51:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a54:	50                   	push   %eax
  800a55:	53                   	push   %ebx
  800a56:	e8 86 fd ff ff       	call   8007e1 <fd_lookup>
  800a5b:	83 c4 08             	add    $0x8,%esp
  800a5e:	89 c2                	mov    %eax,%edx
  800a60:	85 c0                	test   %eax,%eax
  800a62:	78 6d                	js     800ad1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a64:	83 ec 08             	sub    $0x8,%esp
  800a67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a6a:	50                   	push   %eax
  800a6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a6e:	ff 30                	pushl  (%eax)
  800a70:	e8 c2 fd ff ff       	call   800837 <dev_lookup>
  800a75:	83 c4 10             	add    $0x10,%esp
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	78 4c                	js     800ac8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a7f:	8b 42 08             	mov    0x8(%edx),%eax
  800a82:	83 e0 03             	and    $0x3,%eax
  800a85:	83 f8 01             	cmp    $0x1,%eax
  800a88:	75 21                	jne    800aab <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a8a:	a1 04 40 80 00       	mov    0x804004,%eax
  800a8f:	8b 40 48             	mov    0x48(%eax),%eax
  800a92:	83 ec 04             	sub    $0x4,%esp
  800a95:	53                   	push   %ebx
  800a96:	50                   	push   %eax
  800a97:	68 5d 1f 80 00       	push   $0x801f5d
  800a9c:	e8 93 0a 00 00       	call   801534 <cprintf>
		return -E_INVAL;
  800aa1:	83 c4 10             	add    $0x10,%esp
  800aa4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800aa9:	eb 26                	jmp    800ad1 <read+0x8a>
	}
	if (!dev->dev_read)
  800aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aae:	8b 40 08             	mov    0x8(%eax),%eax
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	74 17                	je     800acc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800ab5:	83 ec 04             	sub    $0x4,%esp
  800ab8:	ff 75 10             	pushl  0x10(%ebp)
  800abb:	ff 75 0c             	pushl  0xc(%ebp)
  800abe:	52                   	push   %edx
  800abf:	ff d0                	call   *%eax
  800ac1:	89 c2                	mov    %eax,%edx
  800ac3:	83 c4 10             	add    $0x10,%esp
  800ac6:	eb 09                	jmp    800ad1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ac8:	89 c2                	mov    %eax,%edx
  800aca:	eb 05                	jmp    800ad1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800acc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800ad1:	89 d0                	mov    %edx,%eax
  800ad3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ad6:	c9                   	leave  
  800ad7:	c3                   	ret    

00800ad8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	83 ec 0c             	sub    $0xc,%esp
  800ae1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800ae7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aec:	eb 21                	jmp    800b0f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800aee:	83 ec 04             	sub    $0x4,%esp
  800af1:	89 f0                	mov    %esi,%eax
  800af3:	29 d8                	sub    %ebx,%eax
  800af5:	50                   	push   %eax
  800af6:	89 d8                	mov    %ebx,%eax
  800af8:	03 45 0c             	add    0xc(%ebp),%eax
  800afb:	50                   	push   %eax
  800afc:	57                   	push   %edi
  800afd:	e8 45 ff ff ff       	call   800a47 <read>
		if (m < 0)
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	85 c0                	test   %eax,%eax
  800b07:	78 10                	js     800b19 <readn+0x41>
			return m;
		if (m == 0)
  800b09:	85 c0                	test   %eax,%eax
  800b0b:	74 0a                	je     800b17 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b0d:	01 c3                	add    %eax,%ebx
  800b0f:	39 f3                	cmp    %esi,%ebx
  800b11:	72 db                	jb     800aee <readn+0x16>
  800b13:	89 d8                	mov    %ebx,%eax
  800b15:	eb 02                	jmp    800b19 <readn+0x41>
  800b17:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800b19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	53                   	push   %ebx
  800b25:	83 ec 14             	sub    $0x14,%esp
  800b28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b2b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b2e:	50                   	push   %eax
  800b2f:	53                   	push   %ebx
  800b30:	e8 ac fc ff ff       	call   8007e1 <fd_lookup>
  800b35:	83 c4 08             	add    $0x8,%esp
  800b38:	89 c2                	mov    %eax,%edx
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	78 68                	js     800ba6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b3e:	83 ec 08             	sub    $0x8,%esp
  800b41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b44:	50                   	push   %eax
  800b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b48:	ff 30                	pushl  (%eax)
  800b4a:	e8 e8 fc ff ff       	call   800837 <dev_lookup>
  800b4f:	83 c4 10             	add    $0x10,%esp
  800b52:	85 c0                	test   %eax,%eax
  800b54:	78 47                	js     800b9d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b59:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b5d:	75 21                	jne    800b80 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b5f:	a1 04 40 80 00       	mov    0x804004,%eax
  800b64:	8b 40 48             	mov    0x48(%eax),%eax
  800b67:	83 ec 04             	sub    $0x4,%esp
  800b6a:	53                   	push   %ebx
  800b6b:	50                   	push   %eax
  800b6c:	68 79 1f 80 00       	push   $0x801f79
  800b71:	e8 be 09 00 00       	call   801534 <cprintf>
		return -E_INVAL;
  800b76:	83 c4 10             	add    $0x10,%esp
  800b79:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b7e:	eb 26                	jmp    800ba6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b83:	8b 52 0c             	mov    0xc(%edx),%edx
  800b86:	85 d2                	test   %edx,%edx
  800b88:	74 17                	je     800ba1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b8a:	83 ec 04             	sub    $0x4,%esp
  800b8d:	ff 75 10             	pushl  0x10(%ebp)
  800b90:	ff 75 0c             	pushl  0xc(%ebp)
  800b93:	50                   	push   %eax
  800b94:	ff d2                	call   *%edx
  800b96:	89 c2                	mov    %eax,%edx
  800b98:	83 c4 10             	add    $0x10,%esp
  800b9b:	eb 09                	jmp    800ba6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b9d:	89 c2                	mov    %eax,%edx
  800b9f:	eb 05                	jmp    800ba6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ba1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800ba6:	89 d0                	mov    %edx,%eax
  800ba8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <seek>:

int
seek(int fdnum, off_t offset)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800bb3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800bb6:	50                   	push   %eax
  800bb7:	ff 75 08             	pushl  0x8(%ebp)
  800bba:	e8 22 fc ff ff       	call   8007e1 <fd_lookup>
  800bbf:	83 c4 08             	add    $0x8,%esp
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	78 0e                	js     800bd4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800bc6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800bcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd4:	c9                   	leave  
  800bd5:	c3                   	ret    

00800bd6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 14             	sub    $0x14,%esp
  800bdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800be0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800be3:	50                   	push   %eax
  800be4:	53                   	push   %ebx
  800be5:	e8 f7 fb ff ff       	call   8007e1 <fd_lookup>
  800bea:	83 c4 08             	add    $0x8,%esp
  800bed:	89 c2                	mov    %eax,%edx
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	78 65                	js     800c58 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bf3:	83 ec 08             	sub    $0x8,%esp
  800bf6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bf9:	50                   	push   %eax
  800bfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bfd:	ff 30                	pushl  (%eax)
  800bff:	e8 33 fc ff ff       	call   800837 <dev_lookup>
  800c04:	83 c4 10             	add    $0x10,%esp
  800c07:	85 c0                	test   %eax,%eax
  800c09:	78 44                	js     800c4f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c0e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c12:	75 21                	jne    800c35 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c14:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c19:	8b 40 48             	mov    0x48(%eax),%eax
  800c1c:	83 ec 04             	sub    $0x4,%esp
  800c1f:	53                   	push   %ebx
  800c20:	50                   	push   %eax
  800c21:	68 3c 1f 80 00       	push   $0x801f3c
  800c26:	e8 09 09 00 00       	call   801534 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c33:	eb 23                	jmp    800c58 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800c35:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c38:	8b 52 18             	mov    0x18(%edx),%edx
  800c3b:	85 d2                	test   %edx,%edx
  800c3d:	74 14                	je     800c53 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c3f:	83 ec 08             	sub    $0x8,%esp
  800c42:	ff 75 0c             	pushl  0xc(%ebp)
  800c45:	50                   	push   %eax
  800c46:	ff d2                	call   *%edx
  800c48:	89 c2                	mov    %eax,%edx
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	eb 09                	jmp    800c58 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c4f:	89 c2                	mov    %eax,%edx
  800c51:	eb 05                	jmp    800c58 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800c53:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800c58:	89 d0                	mov    %edx,%eax
  800c5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	53                   	push   %ebx
  800c63:	83 ec 14             	sub    $0x14,%esp
  800c66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c6c:	50                   	push   %eax
  800c6d:	ff 75 08             	pushl  0x8(%ebp)
  800c70:	e8 6c fb ff ff       	call   8007e1 <fd_lookup>
  800c75:	83 c4 08             	add    $0x8,%esp
  800c78:	89 c2                	mov    %eax,%edx
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	78 58                	js     800cd6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c7e:	83 ec 08             	sub    $0x8,%esp
  800c81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c84:	50                   	push   %eax
  800c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c88:	ff 30                	pushl  (%eax)
  800c8a:	e8 a8 fb ff ff       	call   800837 <dev_lookup>
  800c8f:	83 c4 10             	add    $0x10,%esp
  800c92:	85 c0                	test   %eax,%eax
  800c94:	78 37                	js     800ccd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c99:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c9d:	74 32                	je     800cd1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c9f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800ca2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ca9:	00 00 00 
	stat->st_isdir = 0;
  800cac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cb3:	00 00 00 
	stat->st_dev = dev;
  800cb6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800cbc:	83 ec 08             	sub    $0x8,%esp
  800cbf:	53                   	push   %ebx
  800cc0:	ff 75 f0             	pushl  -0x10(%ebp)
  800cc3:	ff 50 14             	call   *0x14(%eax)
  800cc6:	89 c2                	mov    %eax,%edx
  800cc8:	83 c4 10             	add    $0x10,%esp
  800ccb:	eb 09                	jmp    800cd6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ccd:	89 c2                	mov    %eax,%edx
  800ccf:	eb 05                	jmp    800cd6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800cd1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800cd6:	89 d0                	mov    %edx,%eax
  800cd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800ce2:	83 ec 08             	sub    $0x8,%esp
  800ce5:	6a 00                	push   $0x0
  800ce7:	ff 75 08             	pushl  0x8(%ebp)
  800cea:	e8 e9 01 00 00       	call   800ed8 <open>
  800cef:	89 c3                	mov    %eax,%ebx
  800cf1:	83 c4 10             	add    $0x10,%esp
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	78 1b                	js     800d13 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800cf8:	83 ec 08             	sub    $0x8,%esp
  800cfb:	ff 75 0c             	pushl  0xc(%ebp)
  800cfe:	50                   	push   %eax
  800cff:	e8 5b ff ff ff       	call   800c5f <fstat>
  800d04:	89 c6                	mov    %eax,%esi
	close(fd);
  800d06:	89 1c 24             	mov    %ebx,(%esp)
  800d09:	e8 fd fb ff ff       	call   80090b <close>
	return r;
  800d0e:	83 c4 10             	add    $0x10,%esp
  800d11:	89 f0                	mov    %esi,%eax
}
  800d13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	89 c6                	mov    %eax,%esi
  800d21:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d23:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d2a:	75 12                	jne    800d3e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	6a 01                	push   $0x1
  800d31:	e8 9f 0e 00 00       	call   801bd5 <ipc_find_env>
  800d36:	a3 00 40 80 00       	mov    %eax,0x804000
  800d3b:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d3e:	6a 07                	push   $0x7
  800d40:	68 00 50 80 00       	push   $0x805000
  800d45:	56                   	push   %esi
  800d46:	ff 35 00 40 80 00    	pushl  0x804000
  800d4c:	e8 30 0e 00 00       	call   801b81 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  800d51:	83 c4 0c             	add    $0xc,%esp
  800d54:	6a 00                	push   $0x0
  800d56:	53                   	push   %ebx
  800d57:	6a 00                	push   $0x0
  800d59:	e8 a1 0d 00 00       	call   801aff <ipc_recv>
}
  800d5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	8b 40 0c             	mov    0xc(%eax),%eax
  800d71:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d79:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d83:	b8 02 00 00 00       	mov    $0x2,%eax
  800d88:	e8 8d ff ff ff       	call   800d1a <fsipc>
}
  800d8d:	c9                   	leave  
  800d8e:	c3                   	ret    

00800d8f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d95:	8b 45 08             	mov    0x8(%ebp),%eax
  800d98:	8b 40 0c             	mov    0xc(%eax),%eax
  800d9b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800da0:	ba 00 00 00 00       	mov    $0x0,%edx
  800da5:	b8 06 00 00 00       	mov    $0x6,%eax
  800daa:	e8 6b ff ff ff       	call   800d1a <fsipc>
}
  800daf:	c9                   	leave  
  800db0:	c3                   	ret    

00800db1 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	53                   	push   %ebx
  800db5:	83 ec 04             	sub    $0x4,%esp
  800db8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	8b 40 0c             	mov    0xc(%eax),%eax
  800dc1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800dc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcb:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd0:	e8 45 ff ff ff       	call   800d1a <fsipc>
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	78 2c                	js     800e05 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800dd9:	83 ec 08             	sub    $0x8,%esp
  800ddc:	68 00 50 80 00       	push   $0x805000
  800de1:	53                   	push   %ebx
  800de2:	e8 90 f3 ff ff       	call   800177 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800de7:	a1 80 50 80 00       	mov    0x805080,%eax
  800dec:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800df2:	a1 84 50 80 00       	mov    0x805084,%eax
  800df7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800dfd:	83 c4 10             	add    $0x10,%esp
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e08:	c9                   	leave  
  800e09:	c3                   	ret    

00800e0a <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	83 ec 0c             	sub    $0xc,%esp
  800e10:	8b 45 10             	mov    0x10(%ebp),%eax
  800e13:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800e18:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800e1d:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	8b 52 0c             	mov    0xc(%edx),%edx
  800e26:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  800e2c:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  800e31:	50                   	push   %eax
  800e32:	ff 75 0c             	pushl  0xc(%ebp)
  800e35:	68 08 50 80 00       	push   $0x805008
  800e3a:	e8 ca f4 ff ff       	call   800309 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800e3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e44:	b8 04 00 00 00       	mov    $0x4,%eax
  800e49:	e8 cc fe ff ff       	call   800d1a <fsipc>
            return r;

    return r;
}
  800e4e:	c9                   	leave  
  800e4f:	c3                   	ret    

00800e50 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
  800e55:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e58:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5b:	8b 40 0c             	mov    0xc(%eax),%eax
  800e5e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e63:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e69:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6e:	b8 03 00 00 00       	mov    $0x3,%eax
  800e73:	e8 a2 fe ff ff       	call   800d1a <fsipc>
  800e78:	89 c3                	mov    %eax,%ebx
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	78 51                	js     800ecf <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800e7e:	39 c6                	cmp    %eax,%esi
  800e80:	73 19                	jae    800e9b <devfile_read+0x4b>
  800e82:	68 a8 1f 80 00       	push   $0x801fa8
  800e87:	68 af 1f 80 00       	push   $0x801faf
  800e8c:	68 82 00 00 00       	push   $0x82
  800e91:	68 c4 1f 80 00       	push   $0x801fc4
  800e96:	e8 c0 05 00 00       	call   80145b <_panic>
	assert(r <= PGSIZE);
  800e9b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ea0:	7e 19                	jle    800ebb <devfile_read+0x6b>
  800ea2:	68 cf 1f 80 00       	push   $0x801fcf
  800ea7:	68 af 1f 80 00       	push   $0x801faf
  800eac:	68 83 00 00 00       	push   $0x83
  800eb1:	68 c4 1f 80 00       	push   $0x801fc4
  800eb6:	e8 a0 05 00 00       	call   80145b <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ebb:	83 ec 04             	sub    $0x4,%esp
  800ebe:	50                   	push   %eax
  800ebf:	68 00 50 80 00       	push   $0x805000
  800ec4:	ff 75 0c             	pushl  0xc(%ebp)
  800ec7:	e8 3d f4 ff ff       	call   800309 <memmove>
	return r;
  800ecc:	83 c4 10             	add    $0x10,%esp
}
  800ecf:	89 d8                	mov    %ebx,%eax
  800ed1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	53                   	push   %ebx
  800edc:	83 ec 20             	sub    $0x20,%esp
  800edf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ee2:	53                   	push   %ebx
  800ee3:	e8 56 f2 ff ff       	call   80013e <strlen>
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ef0:	7f 67                	jg     800f59 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ef2:	83 ec 0c             	sub    $0xc,%esp
  800ef5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef8:	50                   	push   %eax
  800ef9:	e8 94 f8 ff ff       	call   800792 <fd_alloc>
  800efe:	83 c4 10             	add    $0x10,%esp
		return r;
  800f01:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f03:	85 c0                	test   %eax,%eax
  800f05:	78 57                	js     800f5e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800f07:	83 ec 08             	sub    $0x8,%esp
  800f0a:	53                   	push   %ebx
  800f0b:	68 00 50 80 00       	push   $0x805000
  800f10:	e8 62 f2 ff ff       	call   800177 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f18:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f20:	b8 01 00 00 00       	mov    $0x1,%eax
  800f25:	e8 f0 fd ff ff       	call   800d1a <fsipc>
  800f2a:	89 c3                	mov    %eax,%ebx
  800f2c:	83 c4 10             	add    $0x10,%esp
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	79 14                	jns    800f47 <open+0x6f>
		fd_close(fd, 0);
  800f33:	83 ec 08             	sub    $0x8,%esp
  800f36:	6a 00                	push   $0x0
  800f38:	ff 75 f4             	pushl  -0xc(%ebp)
  800f3b:	e8 4a f9 ff ff       	call   80088a <fd_close>
		return r;
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	89 da                	mov    %ebx,%edx
  800f45:	eb 17                	jmp    800f5e <open+0x86>
	}

	return fd2num(fd);
  800f47:	83 ec 0c             	sub    $0xc,%esp
  800f4a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f4d:	e8 19 f8 ff ff       	call   80076b <fd2num>
  800f52:	89 c2                	mov    %eax,%edx
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	eb 05                	jmp    800f5e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f59:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800f5e:	89 d0                	mov    %edx,%eax
  800f60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    

00800f65 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f70:	b8 08 00 00 00       	mov    $0x8,%eax
  800f75:	e8 a0 fd ff ff       	call   800d1a <fsipc>
}
  800f7a:	c9                   	leave  
  800f7b:	c3                   	ret    

00800f7c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	56                   	push   %esi
  800f80:	53                   	push   %ebx
  800f81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f84:	83 ec 0c             	sub    $0xc,%esp
  800f87:	ff 75 08             	pushl  0x8(%ebp)
  800f8a:	e8 ec f7 ff ff       	call   80077b <fd2data>
  800f8f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f91:	83 c4 08             	add    $0x8,%esp
  800f94:	68 db 1f 80 00       	push   $0x801fdb
  800f99:	53                   	push   %ebx
  800f9a:	e8 d8 f1 ff ff       	call   800177 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f9f:	8b 46 04             	mov    0x4(%esi),%eax
  800fa2:	2b 06                	sub    (%esi),%eax
  800fa4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800faa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800fb1:	00 00 00 
	stat->st_dev = &devpipe;
  800fb4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800fbb:	30 80 00 
	return 0;
}
  800fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc6:	5b                   	pop    %ebx
  800fc7:	5e                   	pop    %esi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	53                   	push   %ebx
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800fd4:	53                   	push   %ebx
  800fd5:	6a 00                	push   $0x0
  800fd7:	e8 23 f6 ff ff       	call   8005ff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800fdc:	89 1c 24             	mov    %ebx,(%esp)
  800fdf:	e8 97 f7 ff ff       	call   80077b <fd2data>
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	50                   	push   %eax
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 10 f6 ff ff       	call   8005ff <sys_page_unmap>
}
  800fef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	57                   	push   %edi
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
  800ffa:	83 ec 1c             	sub    $0x1c,%esp
  800ffd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801000:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801002:	a1 04 40 80 00       	mov    0x804004,%eax
  801007:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	ff 75 e0             	pushl  -0x20(%ebp)
  801010:	e8 f9 0b 00 00       	call   801c0e <pageref>
  801015:	89 c3                	mov    %eax,%ebx
  801017:	89 3c 24             	mov    %edi,(%esp)
  80101a:	e8 ef 0b 00 00       	call   801c0e <pageref>
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	39 c3                	cmp    %eax,%ebx
  801024:	0f 94 c1             	sete   %cl
  801027:	0f b6 c9             	movzbl %cl,%ecx
  80102a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80102d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801033:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801036:	39 ce                	cmp    %ecx,%esi
  801038:	74 1b                	je     801055 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80103a:	39 c3                	cmp    %eax,%ebx
  80103c:	75 c4                	jne    801002 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80103e:	8b 42 58             	mov    0x58(%edx),%eax
  801041:	ff 75 e4             	pushl  -0x1c(%ebp)
  801044:	50                   	push   %eax
  801045:	56                   	push   %esi
  801046:	68 e2 1f 80 00       	push   $0x801fe2
  80104b:	e8 e4 04 00 00       	call   801534 <cprintf>
  801050:	83 c4 10             	add    $0x10,%esp
  801053:	eb ad                	jmp    801002 <_pipeisclosed+0xe>
	}
}
  801055:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801058:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	53                   	push   %ebx
  801066:	83 ec 28             	sub    $0x28,%esp
  801069:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80106c:	56                   	push   %esi
  80106d:	e8 09 f7 ff ff       	call   80077b <fd2data>
  801072:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	bf 00 00 00 00       	mov    $0x0,%edi
  80107c:	eb 4b                	jmp    8010c9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80107e:	89 da                	mov    %ebx,%edx
  801080:	89 f0                	mov    %esi,%eax
  801082:	e8 6d ff ff ff       	call   800ff4 <_pipeisclosed>
  801087:	85 c0                	test   %eax,%eax
  801089:	75 48                	jne    8010d3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80108b:	e8 cb f4 ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801090:	8b 43 04             	mov    0x4(%ebx),%eax
  801093:	8b 0b                	mov    (%ebx),%ecx
  801095:	8d 51 20             	lea    0x20(%ecx),%edx
  801098:	39 d0                	cmp    %edx,%eax
  80109a:	73 e2                	jae    80107e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80109c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80109f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8010a3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8010a6:	89 c2                	mov    %eax,%edx
  8010a8:	c1 fa 1f             	sar    $0x1f,%edx
  8010ab:	89 d1                	mov    %edx,%ecx
  8010ad:	c1 e9 1b             	shr    $0x1b,%ecx
  8010b0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8010b3:	83 e2 1f             	and    $0x1f,%edx
  8010b6:	29 ca                	sub    %ecx,%edx
  8010b8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8010bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8010c0:	83 c0 01             	add    $0x1,%eax
  8010c3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010c6:	83 c7 01             	add    $0x1,%edi
  8010c9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010cc:	75 c2                	jne    801090 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8010ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d1:	eb 05                	jmp    8010d8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010d3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8010d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	57                   	push   %edi
  8010e4:	56                   	push   %esi
  8010e5:	53                   	push   %ebx
  8010e6:	83 ec 18             	sub    $0x18,%esp
  8010e9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8010ec:	57                   	push   %edi
  8010ed:	e8 89 f6 ff ff       	call   80077b <fd2data>
  8010f2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fc:	eb 3d                	jmp    80113b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8010fe:	85 db                	test   %ebx,%ebx
  801100:	74 04                	je     801106 <devpipe_read+0x26>
				return i;
  801102:	89 d8                	mov    %ebx,%eax
  801104:	eb 44                	jmp    80114a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801106:	89 f2                	mov    %esi,%edx
  801108:	89 f8                	mov    %edi,%eax
  80110a:	e8 e5 fe ff ff       	call   800ff4 <_pipeisclosed>
  80110f:	85 c0                	test   %eax,%eax
  801111:	75 32                	jne    801145 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801113:	e8 43 f4 ff ff       	call   80055b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801118:	8b 06                	mov    (%esi),%eax
  80111a:	3b 46 04             	cmp    0x4(%esi),%eax
  80111d:	74 df                	je     8010fe <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80111f:	99                   	cltd   
  801120:	c1 ea 1b             	shr    $0x1b,%edx
  801123:	01 d0                	add    %edx,%eax
  801125:	83 e0 1f             	and    $0x1f,%eax
  801128:	29 d0                	sub    %edx,%eax
  80112a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80112f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801132:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801135:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801138:	83 c3 01             	add    $0x1,%ebx
  80113b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80113e:	75 d8                	jne    801118 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801140:	8b 45 10             	mov    0x10(%ebp),%eax
  801143:	eb 05                	jmp    80114a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801145:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80114a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114d:	5b                   	pop    %ebx
  80114e:	5e                   	pop    %esi
  80114f:	5f                   	pop    %edi
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	56                   	push   %esi
  801156:	53                   	push   %ebx
  801157:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80115a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115d:	50                   	push   %eax
  80115e:	e8 2f f6 ff ff       	call   800792 <fd_alloc>
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	89 c2                	mov    %eax,%edx
  801168:	85 c0                	test   %eax,%eax
  80116a:	0f 88 2c 01 00 00    	js     80129c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801170:	83 ec 04             	sub    $0x4,%esp
  801173:	68 07 04 00 00       	push   $0x407
  801178:	ff 75 f4             	pushl  -0xc(%ebp)
  80117b:	6a 00                	push   $0x0
  80117d:	e8 f8 f3 ff ff       	call   80057a <sys_page_alloc>
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	89 c2                	mov    %eax,%edx
  801187:	85 c0                	test   %eax,%eax
  801189:	0f 88 0d 01 00 00    	js     80129c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80118f:	83 ec 0c             	sub    $0xc,%esp
  801192:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	e8 f7 f5 ff ff       	call   800792 <fd_alloc>
  80119b:	89 c3                	mov    %eax,%ebx
  80119d:	83 c4 10             	add    $0x10,%esp
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	0f 88 e2 00 00 00    	js     80128a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011a8:	83 ec 04             	sub    $0x4,%esp
  8011ab:	68 07 04 00 00       	push   $0x407
  8011b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8011b3:	6a 00                	push   $0x0
  8011b5:	e8 c0 f3 ff ff       	call   80057a <sys_page_alloc>
  8011ba:	89 c3                	mov    %eax,%ebx
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	0f 88 c3 00 00 00    	js     80128a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8011c7:	83 ec 0c             	sub    $0xc,%esp
  8011ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8011cd:	e8 a9 f5 ff ff       	call   80077b <fd2data>
  8011d2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011d4:	83 c4 0c             	add    $0xc,%esp
  8011d7:	68 07 04 00 00       	push   $0x407
  8011dc:	50                   	push   %eax
  8011dd:	6a 00                	push   $0x0
  8011df:	e8 96 f3 ff ff       	call   80057a <sys_page_alloc>
  8011e4:	89 c3                	mov    %eax,%ebx
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	0f 88 89 00 00 00    	js     80127a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f1:	83 ec 0c             	sub    $0xc,%esp
  8011f4:	ff 75 f0             	pushl  -0x10(%ebp)
  8011f7:	e8 7f f5 ff ff       	call   80077b <fd2data>
  8011fc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801203:	50                   	push   %eax
  801204:	6a 00                	push   $0x0
  801206:	56                   	push   %esi
  801207:	6a 00                	push   $0x0
  801209:	e8 af f3 ff ff       	call   8005bd <sys_page_map>
  80120e:	89 c3                	mov    %eax,%ebx
  801210:	83 c4 20             	add    $0x20,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	78 55                	js     80126c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801217:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80121d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801220:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801225:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80122c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801232:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801235:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801237:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801241:	83 ec 0c             	sub    $0xc,%esp
  801244:	ff 75 f4             	pushl  -0xc(%ebp)
  801247:	e8 1f f5 ff ff       	call   80076b <fd2num>
  80124c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801251:	83 c4 04             	add    $0x4,%esp
  801254:	ff 75 f0             	pushl  -0x10(%ebp)
  801257:	e8 0f f5 ff ff       	call   80076b <fd2num>
  80125c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	ba 00 00 00 00       	mov    $0x0,%edx
  80126a:	eb 30                	jmp    80129c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80126c:	83 ec 08             	sub    $0x8,%esp
  80126f:	56                   	push   %esi
  801270:	6a 00                	push   $0x0
  801272:	e8 88 f3 ff ff       	call   8005ff <sys_page_unmap>
  801277:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80127a:	83 ec 08             	sub    $0x8,%esp
  80127d:	ff 75 f0             	pushl  -0x10(%ebp)
  801280:	6a 00                	push   $0x0
  801282:	e8 78 f3 ff ff       	call   8005ff <sys_page_unmap>
  801287:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	ff 75 f4             	pushl  -0xc(%ebp)
  801290:	6a 00                	push   $0x0
  801292:	e8 68 f3 ff ff       	call   8005ff <sys_page_unmap>
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80129c:	89 d0                	mov    %edx,%eax
  80129e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a1:	5b                   	pop    %ebx
  8012a2:	5e                   	pop    %esi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    

008012a5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ae:	50                   	push   %eax
  8012af:	ff 75 08             	pushl  0x8(%ebp)
  8012b2:	e8 2a f5 ff ff       	call   8007e1 <fd_lookup>
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	78 18                	js     8012d6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8012be:	83 ec 0c             	sub    $0xc,%esp
  8012c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c4:	e8 b2 f4 ff ff       	call   80077b <fd2data>
	return _pipeisclosed(fd, p);
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ce:	e8 21 fd ff ff       	call   800ff4 <_pipeisclosed>
  8012d3:	83 c4 10             	add    $0x10,%esp
}
  8012d6:	c9                   	leave  
  8012d7:	c3                   	ret    

008012d8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8012db:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8012e8:	68 fa 1f 80 00       	push   $0x801ffa
  8012ed:	ff 75 0c             	pushl  0xc(%ebp)
  8012f0:	e8 82 ee ff ff       	call   800177 <strcpy>
	return 0;
}
  8012f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fa:	c9                   	leave  
  8012fb:	c3                   	ret    

008012fc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	57                   	push   %edi
  801300:	56                   	push   %esi
  801301:	53                   	push   %ebx
  801302:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801308:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80130d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801313:	eb 2d                	jmp    801342 <devcons_write+0x46>
		m = n - tot;
  801315:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801318:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80131a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80131d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801322:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801325:	83 ec 04             	sub    $0x4,%esp
  801328:	53                   	push   %ebx
  801329:	03 45 0c             	add    0xc(%ebp),%eax
  80132c:	50                   	push   %eax
  80132d:	57                   	push   %edi
  80132e:	e8 d6 ef ff ff       	call   800309 <memmove>
		sys_cputs(buf, m);
  801333:	83 c4 08             	add    $0x8,%esp
  801336:	53                   	push   %ebx
  801337:	57                   	push   %edi
  801338:	e8 81 f1 ff ff       	call   8004be <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80133d:	01 de                	add    %ebx,%esi
  80133f:	83 c4 10             	add    $0x10,%esp
  801342:	89 f0                	mov    %esi,%eax
  801344:	3b 75 10             	cmp    0x10(%ebp),%esi
  801347:	72 cc                	jb     801315 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801349:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80134c:	5b                   	pop    %ebx
  80134d:	5e                   	pop    %esi
  80134e:	5f                   	pop    %edi
  80134f:	5d                   	pop    %ebp
  801350:	c3                   	ret    

00801351 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	83 ec 08             	sub    $0x8,%esp
  801357:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80135c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801360:	74 2a                	je     80138c <devcons_read+0x3b>
  801362:	eb 05                	jmp    801369 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801364:	e8 f2 f1 ff ff       	call   80055b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801369:	e8 6e f1 ff ff       	call   8004dc <sys_cgetc>
  80136e:	85 c0                	test   %eax,%eax
  801370:	74 f2                	je     801364 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801372:	85 c0                	test   %eax,%eax
  801374:	78 16                	js     80138c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801376:	83 f8 04             	cmp    $0x4,%eax
  801379:	74 0c                	je     801387 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80137b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137e:	88 02                	mov    %al,(%edx)
	return 1;
  801380:	b8 01 00 00 00       	mov    $0x1,%eax
  801385:	eb 05                	jmp    80138c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801387:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801394:	8b 45 08             	mov    0x8(%ebp),%eax
  801397:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80139a:	6a 01                	push   $0x1
  80139c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80139f:	50                   	push   %eax
  8013a0:	e8 19 f1 ff ff       	call   8004be <sys_cputs>
}
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <getchar>:

int
getchar(void)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8013b0:	6a 01                	push   $0x1
  8013b2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013b5:	50                   	push   %eax
  8013b6:	6a 00                	push   $0x0
  8013b8:	e8 8a f6 ff ff       	call   800a47 <read>
	if (r < 0)
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	78 0f                	js     8013d3 <getchar+0x29>
		return r;
	if (r < 1)
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	7e 06                	jle    8013ce <getchar+0x24>
		return -E_EOF;
	return c;
  8013c8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8013cc:	eb 05                	jmp    8013d3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8013ce:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8013d3:	c9                   	leave  
  8013d4:	c3                   	ret    

008013d5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013de:	50                   	push   %eax
  8013df:	ff 75 08             	pushl  0x8(%ebp)
  8013e2:	e8 fa f3 ff ff       	call   8007e1 <fd_lookup>
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	78 11                	js     8013ff <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8013ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013f7:	39 10                	cmp    %edx,(%eax)
  8013f9:	0f 94 c0             	sete   %al
  8013fc:	0f b6 c0             	movzbl %al,%eax
}
  8013ff:	c9                   	leave  
  801400:	c3                   	ret    

00801401 <opencons>:

int
opencons(void)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801407:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140a:	50                   	push   %eax
  80140b:	e8 82 f3 ff ff       	call   800792 <fd_alloc>
  801410:	83 c4 10             	add    $0x10,%esp
		return r;
  801413:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801415:	85 c0                	test   %eax,%eax
  801417:	78 3e                	js     801457 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801419:	83 ec 04             	sub    $0x4,%esp
  80141c:	68 07 04 00 00       	push   $0x407
  801421:	ff 75 f4             	pushl  -0xc(%ebp)
  801424:	6a 00                	push   $0x0
  801426:	e8 4f f1 ff ff       	call   80057a <sys_page_alloc>
  80142b:	83 c4 10             	add    $0x10,%esp
		return r;
  80142e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801430:	85 c0                	test   %eax,%eax
  801432:	78 23                	js     801457 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801434:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80143a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80143f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801442:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801449:	83 ec 0c             	sub    $0xc,%esp
  80144c:	50                   	push   %eax
  80144d:	e8 19 f3 ff ff       	call   80076b <fd2num>
  801452:	89 c2                	mov    %eax,%edx
  801454:	83 c4 10             	add    $0x10,%esp
}
  801457:	89 d0                	mov    %edx,%eax
  801459:	c9                   	leave  
  80145a:	c3                   	ret    

0080145b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	56                   	push   %esi
  80145f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801460:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801463:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801469:	e8 ce f0 ff ff       	call   80053c <sys_getenvid>
  80146e:	83 ec 0c             	sub    $0xc,%esp
  801471:	ff 75 0c             	pushl  0xc(%ebp)
  801474:	ff 75 08             	pushl  0x8(%ebp)
  801477:	56                   	push   %esi
  801478:	50                   	push   %eax
  801479:	68 08 20 80 00       	push   $0x802008
  80147e:	e8 b1 00 00 00       	call   801534 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801483:	83 c4 18             	add    $0x18,%esp
  801486:	53                   	push   %ebx
  801487:	ff 75 10             	pushl  0x10(%ebp)
  80148a:	e8 54 00 00 00       	call   8014e3 <vcprintf>
	cprintf("\n");
  80148f:	c7 04 24 f3 1f 80 00 	movl   $0x801ff3,(%esp)
  801496:	e8 99 00 00 00       	call   801534 <cprintf>
  80149b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80149e:	cc                   	int3   
  80149f:	eb fd                	jmp    80149e <_panic+0x43>

008014a1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014a1:	55                   	push   %ebp
  8014a2:	89 e5                	mov    %esp,%ebp
  8014a4:	53                   	push   %ebx
  8014a5:	83 ec 04             	sub    $0x4,%esp
  8014a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8014ab:	8b 13                	mov    (%ebx),%edx
  8014ad:	8d 42 01             	lea    0x1(%edx),%eax
  8014b0:	89 03                	mov    %eax,(%ebx)
  8014b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8014b9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8014be:	75 1a                	jne    8014da <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8014c0:	83 ec 08             	sub    $0x8,%esp
  8014c3:	68 ff 00 00 00       	push   $0xff
  8014c8:	8d 43 08             	lea    0x8(%ebx),%eax
  8014cb:	50                   	push   %eax
  8014cc:	e8 ed ef ff ff       	call   8004be <sys_cputs>
		b->idx = 0;
  8014d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8014d7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8014da:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8014de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e1:	c9                   	leave  
  8014e2:	c3                   	ret    

008014e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8014ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8014f3:	00 00 00 
	b.cnt = 0;
  8014f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8014fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801500:	ff 75 0c             	pushl  0xc(%ebp)
  801503:	ff 75 08             	pushl  0x8(%ebp)
  801506:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	68 a1 14 80 00       	push   $0x8014a1
  801512:	e8 1a 01 00 00       	call   801631 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801517:	83 c4 08             	add    $0x8,%esp
  80151a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801520:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801526:	50                   	push   %eax
  801527:	e8 92 ef ff ff       	call   8004be <sys_cputs>

	return b.cnt;
}
  80152c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801532:	c9                   	leave  
  801533:	c3                   	ret    

00801534 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80153a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80153d:	50                   	push   %eax
  80153e:	ff 75 08             	pushl  0x8(%ebp)
  801541:	e8 9d ff ff ff       	call   8014e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	57                   	push   %edi
  80154c:	56                   	push   %esi
  80154d:	53                   	push   %ebx
  80154e:	83 ec 1c             	sub    $0x1c,%esp
  801551:	89 c7                	mov    %eax,%edi
  801553:	89 d6                	mov    %edx,%esi
  801555:	8b 45 08             	mov    0x8(%ebp),%eax
  801558:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80155e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801561:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801564:	bb 00 00 00 00       	mov    $0x0,%ebx
  801569:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80156c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80156f:	39 d3                	cmp    %edx,%ebx
  801571:	72 05                	jb     801578 <printnum+0x30>
  801573:	39 45 10             	cmp    %eax,0x10(%ebp)
  801576:	77 45                	ja     8015bd <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801578:	83 ec 0c             	sub    $0xc,%esp
  80157b:	ff 75 18             	pushl  0x18(%ebp)
  80157e:	8b 45 14             	mov    0x14(%ebp),%eax
  801581:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801584:	53                   	push   %ebx
  801585:	ff 75 10             	pushl  0x10(%ebp)
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80158e:	ff 75 e0             	pushl  -0x20(%ebp)
  801591:	ff 75 dc             	pushl  -0x24(%ebp)
  801594:	ff 75 d8             	pushl  -0x28(%ebp)
  801597:	e8 b4 06 00 00       	call   801c50 <__udivdi3>
  80159c:	83 c4 18             	add    $0x18,%esp
  80159f:	52                   	push   %edx
  8015a0:	50                   	push   %eax
  8015a1:	89 f2                	mov    %esi,%edx
  8015a3:	89 f8                	mov    %edi,%eax
  8015a5:	e8 9e ff ff ff       	call   801548 <printnum>
  8015aa:	83 c4 20             	add    $0x20,%esp
  8015ad:	eb 18                	jmp    8015c7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	56                   	push   %esi
  8015b3:	ff 75 18             	pushl  0x18(%ebp)
  8015b6:	ff d7                	call   *%edi
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	eb 03                	jmp    8015c0 <printnum+0x78>
  8015bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8015c0:	83 eb 01             	sub    $0x1,%ebx
  8015c3:	85 db                	test   %ebx,%ebx
  8015c5:	7f e8                	jg     8015af <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	56                   	push   %esi
  8015cb:	83 ec 04             	sub    $0x4,%esp
  8015ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8015d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8015da:	e8 a1 07 00 00       	call   801d80 <__umoddi3>
  8015df:	83 c4 14             	add    $0x14,%esp
  8015e2:	0f be 80 2b 20 80 00 	movsbl 0x80202b(%eax),%eax
  8015e9:	50                   	push   %eax
  8015ea:	ff d7                	call   *%edi
}
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f2:	5b                   	pop    %ebx
  8015f3:	5e                   	pop    %esi
  8015f4:	5f                   	pop    %edi
  8015f5:	5d                   	pop    %ebp
  8015f6:	c3                   	ret    

008015f7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015fd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801601:	8b 10                	mov    (%eax),%edx
  801603:	3b 50 04             	cmp    0x4(%eax),%edx
  801606:	73 0a                	jae    801612 <sprintputch+0x1b>
		*b->buf++ = ch;
  801608:	8d 4a 01             	lea    0x1(%edx),%ecx
  80160b:	89 08                	mov    %ecx,(%eax)
  80160d:	8b 45 08             	mov    0x8(%ebp),%eax
  801610:	88 02                	mov    %al,(%edx)
}
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80161a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80161d:	50                   	push   %eax
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	ff 75 08             	pushl  0x8(%ebp)
  801627:	e8 05 00 00 00       	call   801631 <vprintfmt>
	va_end(ap);
}
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	57                   	push   %edi
  801635:	56                   	push   %esi
  801636:	53                   	push   %ebx
  801637:	83 ec 2c             	sub    $0x2c,%esp
  80163a:	8b 75 08             	mov    0x8(%ebp),%esi
  80163d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801640:	8b 7d 10             	mov    0x10(%ebp),%edi
  801643:	eb 12                	jmp    801657 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801645:	85 c0                	test   %eax,%eax
  801647:	0f 84 42 04 00 00    	je     801a8f <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	53                   	push   %ebx
  801651:	50                   	push   %eax
  801652:	ff d6                	call   *%esi
  801654:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801657:	83 c7 01             	add    $0x1,%edi
  80165a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80165e:	83 f8 25             	cmp    $0x25,%eax
  801661:	75 e2                	jne    801645 <vprintfmt+0x14>
  801663:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801667:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80166e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801675:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80167c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801681:	eb 07                	jmp    80168a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801683:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801686:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80168a:	8d 47 01             	lea    0x1(%edi),%eax
  80168d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801690:	0f b6 07             	movzbl (%edi),%eax
  801693:	0f b6 d0             	movzbl %al,%edx
  801696:	83 e8 23             	sub    $0x23,%eax
  801699:	3c 55                	cmp    $0x55,%al
  80169b:	0f 87 d3 03 00 00    	ja     801a74 <vprintfmt+0x443>
  8016a1:	0f b6 c0             	movzbl %al,%eax
  8016a4:	ff 24 85 60 21 80 00 	jmp    *0x802160(,%eax,4)
  8016ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8016ae:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8016b2:	eb d6                	jmp    80168a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8016bf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8016c2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8016c6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8016c9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8016cc:	83 f9 09             	cmp    $0x9,%ecx
  8016cf:	77 3f                	ja     801710 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8016d1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8016d4:	eb e9                	jmp    8016bf <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8016d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d9:	8b 00                	mov    (%eax),%eax
  8016db:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8016de:	8b 45 14             	mov    0x14(%ebp),%eax
  8016e1:	8d 40 04             	lea    0x4(%eax),%eax
  8016e4:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8016ea:	eb 2a                	jmp    801716 <vprintfmt+0xe5>
  8016ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f6:	0f 49 d0             	cmovns %eax,%edx
  8016f9:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016ff:	eb 89                	jmp    80168a <vprintfmt+0x59>
  801701:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801704:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80170b:	e9 7a ff ff ff       	jmp    80168a <vprintfmt+0x59>
  801710:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801713:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801716:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80171a:	0f 89 6a ff ff ff    	jns    80168a <vprintfmt+0x59>
				width = precision, precision = -1;
  801720:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801723:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801726:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80172d:	e9 58 ff ff ff       	jmp    80168a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801732:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801735:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801738:	e9 4d ff ff ff       	jmp    80168a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80173d:	8b 45 14             	mov    0x14(%ebp),%eax
  801740:	8d 78 04             	lea    0x4(%eax),%edi
  801743:	83 ec 08             	sub    $0x8,%esp
  801746:	53                   	push   %ebx
  801747:	ff 30                	pushl  (%eax)
  801749:	ff d6                	call   *%esi
			break;
  80174b:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80174e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801751:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801754:	e9 fe fe ff ff       	jmp    801657 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801759:	8b 45 14             	mov    0x14(%ebp),%eax
  80175c:	8d 78 04             	lea    0x4(%eax),%edi
  80175f:	8b 00                	mov    (%eax),%eax
  801761:	99                   	cltd   
  801762:	31 d0                	xor    %edx,%eax
  801764:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801766:	83 f8 0f             	cmp    $0xf,%eax
  801769:	7f 0b                	jg     801776 <vprintfmt+0x145>
  80176b:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  801772:	85 d2                	test   %edx,%edx
  801774:	75 1b                	jne    801791 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801776:	50                   	push   %eax
  801777:	68 43 20 80 00       	push   $0x802043
  80177c:	53                   	push   %ebx
  80177d:	56                   	push   %esi
  80177e:	e8 91 fe ff ff       	call   801614 <printfmt>
  801783:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801786:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801789:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80178c:	e9 c6 fe ff ff       	jmp    801657 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801791:	52                   	push   %edx
  801792:	68 c1 1f 80 00       	push   $0x801fc1
  801797:	53                   	push   %ebx
  801798:	56                   	push   %esi
  801799:	e8 76 fe ff ff       	call   801614 <printfmt>
  80179e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017a1:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017a7:	e9 ab fe ff ff       	jmp    801657 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8017ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8017af:	83 c0 04             	add    $0x4,%eax
  8017b2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8017b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8017ba:	85 ff                	test   %edi,%edi
  8017bc:	b8 3c 20 80 00       	mov    $0x80203c,%eax
  8017c1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8017c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017c8:	0f 8e 94 00 00 00    	jle    801862 <vprintfmt+0x231>
  8017ce:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8017d2:	0f 84 98 00 00 00    	je     801870 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8017d8:	83 ec 08             	sub    $0x8,%esp
  8017db:	ff 75 d0             	pushl  -0x30(%ebp)
  8017de:	57                   	push   %edi
  8017df:	e8 72 e9 ff ff       	call   800156 <strnlen>
  8017e4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8017e7:	29 c1                	sub    %eax,%ecx
  8017e9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8017ec:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8017ef:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8017f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017f6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017f9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017fb:	eb 0f                	jmp    80180c <vprintfmt+0x1db>
					putch(padc, putdat);
  8017fd:	83 ec 08             	sub    $0x8,%esp
  801800:	53                   	push   %ebx
  801801:	ff 75 e0             	pushl  -0x20(%ebp)
  801804:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801806:	83 ef 01             	sub    $0x1,%edi
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	85 ff                	test   %edi,%edi
  80180e:	7f ed                	jg     8017fd <vprintfmt+0x1cc>
  801810:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801813:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801816:	85 c9                	test   %ecx,%ecx
  801818:	b8 00 00 00 00       	mov    $0x0,%eax
  80181d:	0f 49 c1             	cmovns %ecx,%eax
  801820:	29 c1                	sub    %eax,%ecx
  801822:	89 75 08             	mov    %esi,0x8(%ebp)
  801825:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801828:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80182b:	89 cb                	mov    %ecx,%ebx
  80182d:	eb 4d                	jmp    80187c <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80182f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801833:	74 1b                	je     801850 <vprintfmt+0x21f>
  801835:	0f be c0             	movsbl %al,%eax
  801838:	83 e8 20             	sub    $0x20,%eax
  80183b:	83 f8 5e             	cmp    $0x5e,%eax
  80183e:	76 10                	jbe    801850 <vprintfmt+0x21f>
					putch('?', putdat);
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	ff 75 0c             	pushl  0xc(%ebp)
  801846:	6a 3f                	push   $0x3f
  801848:	ff 55 08             	call   *0x8(%ebp)
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	eb 0d                	jmp    80185d <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801850:	83 ec 08             	sub    $0x8,%esp
  801853:	ff 75 0c             	pushl  0xc(%ebp)
  801856:	52                   	push   %edx
  801857:	ff 55 08             	call   *0x8(%ebp)
  80185a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80185d:	83 eb 01             	sub    $0x1,%ebx
  801860:	eb 1a                	jmp    80187c <vprintfmt+0x24b>
  801862:	89 75 08             	mov    %esi,0x8(%ebp)
  801865:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801868:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80186b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80186e:	eb 0c                	jmp    80187c <vprintfmt+0x24b>
  801870:	89 75 08             	mov    %esi,0x8(%ebp)
  801873:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801876:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801879:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80187c:	83 c7 01             	add    $0x1,%edi
  80187f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801883:	0f be d0             	movsbl %al,%edx
  801886:	85 d2                	test   %edx,%edx
  801888:	74 23                	je     8018ad <vprintfmt+0x27c>
  80188a:	85 f6                	test   %esi,%esi
  80188c:	78 a1                	js     80182f <vprintfmt+0x1fe>
  80188e:	83 ee 01             	sub    $0x1,%esi
  801891:	79 9c                	jns    80182f <vprintfmt+0x1fe>
  801893:	89 df                	mov    %ebx,%edi
  801895:	8b 75 08             	mov    0x8(%ebp),%esi
  801898:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80189b:	eb 18                	jmp    8018b5 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80189d:	83 ec 08             	sub    $0x8,%esp
  8018a0:	53                   	push   %ebx
  8018a1:	6a 20                	push   $0x20
  8018a3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018a5:	83 ef 01             	sub    $0x1,%edi
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	eb 08                	jmp    8018b5 <vprintfmt+0x284>
  8018ad:	89 df                	mov    %ebx,%edi
  8018af:	8b 75 08             	mov    0x8(%ebp),%esi
  8018b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018b5:	85 ff                	test   %edi,%edi
  8018b7:	7f e4                	jg     80189d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018b9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8018bc:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018c2:	e9 90 fd ff ff       	jmp    801657 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8018c7:	83 f9 01             	cmp    $0x1,%ecx
  8018ca:	7e 19                	jle    8018e5 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8018cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8018cf:	8b 50 04             	mov    0x4(%eax),%edx
  8018d2:	8b 00                	mov    (%eax),%eax
  8018d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018da:	8b 45 14             	mov    0x14(%ebp),%eax
  8018dd:	8d 40 08             	lea    0x8(%eax),%eax
  8018e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8018e3:	eb 38                	jmp    80191d <vprintfmt+0x2ec>
	else if (lflag)
  8018e5:	85 c9                	test   %ecx,%ecx
  8018e7:	74 1b                	je     801904 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8018e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ec:	8b 00                	mov    (%eax),%eax
  8018ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018f1:	89 c1                	mov    %eax,%ecx
  8018f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8018f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fc:	8d 40 04             	lea    0x4(%eax),%eax
  8018ff:	89 45 14             	mov    %eax,0x14(%ebp)
  801902:	eb 19                	jmp    80191d <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801904:	8b 45 14             	mov    0x14(%ebp),%eax
  801907:	8b 00                	mov    (%eax),%eax
  801909:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80190c:	89 c1                	mov    %eax,%ecx
  80190e:	c1 f9 1f             	sar    $0x1f,%ecx
  801911:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801914:	8b 45 14             	mov    0x14(%ebp),%eax
  801917:	8d 40 04             	lea    0x4(%eax),%eax
  80191a:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80191d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801920:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801923:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801928:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80192c:	0f 89 0e 01 00 00    	jns    801a40 <vprintfmt+0x40f>
				putch('-', putdat);
  801932:	83 ec 08             	sub    $0x8,%esp
  801935:	53                   	push   %ebx
  801936:	6a 2d                	push   $0x2d
  801938:	ff d6                	call   *%esi
				num = -(long long) num;
  80193a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80193d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801940:	f7 da                	neg    %edx
  801942:	83 d1 00             	adc    $0x0,%ecx
  801945:	f7 d9                	neg    %ecx
  801947:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80194a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80194f:	e9 ec 00 00 00       	jmp    801a40 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801954:	83 f9 01             	cmp    $0x1,%ecx
  801957:	7e 18                	jle    801971 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801959:	8b 45 14             	mov    0x14(%ebp),%eax
  80195c:	8b 10                	mov    (%eax),%edx
  80195e:	8b 48 04             	mov    0x4(%eax),%ecx
  801961:	8d 40 08             	lea    0x8(%eax),%eax
  801964:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801967:	b8 0a 00 00 00       	mov    $0xa,%eax
  80196c:	e9 cf 00 00 00       	jmp    801a40 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801971:	85 c9                	test   %ecx,%ecx
  801973:	74 1a                	je     80198f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801975:	8b 45 14             	mov    0x14(%ebp),%eax
  801978:	8b 10                	mov    (%eax),%edx
  80197a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80197f:	8d 40 04             	lea    0x4(%eax),%eax
  801982:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801985:	b8 0a 00 00 00       	mov    $0xa,%eax
  80198a:	e9 b1 00 00 00       	jmp    801a40 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80198f:	8b 45 14             	mov    0x14(%ebp),%eax
  801992:	8b 10                	mov    (%eax),%edx
  801994:	b9 00 00 00 00       	mov    $0x0,%ecx
  801999:	8d 40 04             	lea    0x4(%eax),%eax
  80199c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80199f:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019a4:	e9 97 00 00 00       	jmp    801a40 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8019a9:	83 ec 08             	sub    $0x8,%esp
  8019ac:	53                   	push   %ebx
  8019ad:	6a 58                	push   $0x58
  8019af:	ff d6                	call   *%esi
			putch('X', putdat);
  8019b1:	83 c4 08             	add    $0x8,%esp
  8019b4:	53                   	push   %ebx
  8019b5:	6a 58                	push   $0x58
  8019b7:	ff d6                	call   *%esi
			putch('X', putdat);
  8019b9:	83 c4 08             	add    $0x8,%esp
  8019bc:	53                   	push   %ebx
  8019bd:	6a 58                	push   $0x58
  8019bf:	ff d6                	call   *%esi
			break;
  8019c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8019c7:	e9 8b fc ff ff       	jmp    801657 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8019cc:	83 ec 08             	sub    $0x8,%esp
  8019cf:	53                   	push   %ebx
  8019d0:	6a 30                	push   $0x30
  8019d2:	ff d6                	call   *%esi
			putch('x', putdat);
  8019d4:	83 c4 08             	add    $0x8,%esp
  8019d7:	53                   	push   %ebx
  8019d8:	6a 78                	push   $0x78
  8019da:	ff d6                	call   *%esi
			num = (unsigned long long)
  8019dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019df:	8b 10                	mov    (%eax),%edx
  8019e1:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8019e6:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019e9:	8d 40 04             	lea    0x4(%eax),%eax
  8019ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8019ef:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8019f4:	eb 4a                	jmp    801a40 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019f6:	83 f9 01             	cmp    $0x1,%ecx
  8019f9:	7e 15                	jle    801a10 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8019fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019fe:	8b 10                	mov    (%eax),%edx
  801a00:	8b 48 04             	mov    0x4(%eax),%ecx
  801a03:	8d 40 08             	lea    0x8(%eax),%eax
  801a06:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801a09:	b8 10 00 00 00       	mov    $0x10,%eax
  801a0e:	eb 30                	jmp    801a40 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801a10:	85 c9                	test   %ecx,%ecx
  801a12:	74 17                	je     801a2b <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801a14:	8b 45 14             	mov    0x14(%ebp),%eax
  801a17:	8b 10                	mov    (%eax),%edx
  801a19:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a1e:	8d 40 04             	lea    0x4(%eax),%eax
  801a21:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801a24:	b8 10 00 00 00       	mov    $0x10,%eax
  801a29:	eb 15                	jmp    801a40 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801a2b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2e:	8b 10                	mov    (%eax),%edx
  801a30:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a35:	8d 40 04             	lea    0x4(%eax),%eax
  801a38:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801a3b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a40:	83 ec 0c             	sub    $0xc,%esp
  801a43:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a47:	57                   	push   %edi
  801a48:	ff 75 e0             	pushl  -0x20(%ebp)
  801a4b:	50                   	push   %eax
  801a4c:	51                   	push   %ecx
  801a4d:	52                   	push   %edx
  801a4e:	89 da                	mov    %ebx,%edx
  801a50:	89 f0                	mov    %esi,%eax
  801a52:	e8 f1 fa ff ff       	call   801548 <printnum>
			break;
  801a57:	83 c4 20             	add    $0x20,%esp
  801a5a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a5d:	e9 f5 fb ff ff       	jmp    801657 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a62:	83 ec 08             	sub    $0x8,%esp
  801a65:	53                   	push   %ebx
  801a66:	52                   	push   %edx
  801a67:	ff d6                	call   *%esi
			break;
  801a69:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a6c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a6f:	e9 e3 fb ff ff       	jmp    801657 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a74:	83 ec 08             	sub    $0x8,%esp
  801a77:	53                   	push   %ebx
  801a78:	6a 25                	push   $0x25
  801a7a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	eb 03                	jmp    801a84 <vprintfmt+0x453>
  801a81:	83 ef 01             	sub    $0x1,%edi
  801a84:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a88:	75 f7                	jne    801a81 <vprintfmt+0x450>
  801a8a:	e9 c8 fb ff ff       	jmp    801657 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	5f                   	pop    %edi
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	83 ec 18             	sub    $0x18,%esp
  801a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801aa3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801aa6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801aaa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801aad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	74 26                	je     801ade <vsnprintf+0x47>
  801ab8:	85 d2                	test   %edx,%edx
  801aba:	7e 22                	jle    801ade <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801abc:	ff 75 14             	pushl  0x14(%ebp)
  801abf:	ff 75 10             	pushl  0x10(%ebp)
  801ac2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ac5:	50                   	push   %eax
  801ac6:	68 f7 15 80 00       	push   $0x8015f7
  801acb:	e8 61 fb ff ff       	call   801631 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ad0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ad3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad9:	83 c4 10             	add    $0x10,%esp
  801adc:	eb 05                	jmp    801ae3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ade:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ae3:	c9                   	leave  
  801ae4:	c3                   	ret    

00801ae5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801aeb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801aee:	50                   	push   %eax
  801aef:	ff 75 10             	pushl  0x10(%ebp)
  801af2:	ff 75 0c             	pushl  0xc(%ebp)
  801af5:	ff 75 08             	pushl  0x8(%ebp)
  801af8:	e8 9a ff ff ff       	call   801a97 <vsnprintf>
	va_end(ap);

	return rc;
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	57                   	push   %edi
  801b03:	56                   	push   %esi
  801b04:	53                   	push   %ebx
  801b05:	83 ec 0c             	sub    $0xc,%esp
  801b08:	8b 75 08             	mov    0x8(%ebp),%esi
  801b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801b11:	85 f6                	test   %esi,%esi
  801b13:	74 06                	je     801b1b <ipc_recv+0x1c>
		*from_env_store = 0;
  801b15:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801b1b:	85 db                	test   %ebx,%ebx
  801b1d:	74 06                	je     801b25 <ipc_recv+0x26>
		*perm_store = 0;
  801b1f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801b25:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801b27:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b2c:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801b2f:	83 ec 0c             	sub    $0xc,%esp
  801b32:	50                   	push   %eax
  801b33:	e8 f2 eb ff ff       	call   80072a <sys_ipc_recv>
  801b38:	89 c7                	mov    %eax,%edi
  801b3a:	83 c4 10             	add    $0x10,%esp
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	79 14                	jns    801b55 <ipc_recv+0x56>
		cprintf("im dead");
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	68 20 23 80 00       	push   $0x802320
  801b49:	e8 e6 f9 ff ff       	call   801534 <cprintf>
		return r;
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	89 f8                	mov    %edi,%eax
  801b53:	eb 24                	jmp    801b79 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801b55:	85 f6                	test   %esi,%esi
  801b57:	74 0a                	je     801b63 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801b59:	a1 04 40 80 00       	mov    0x804004,%eax
  801b5e:	8b 40 74             	mov    0x74(%eax),%eax
  801b61:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801b63:	85 db                	test   %ebx,%ebx
  801b65:	74 0a                	je     801b71 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801b67:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6c:	8b 40 78             	mov    0x78(%eax),%eax
  801b6f:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801b71:	a1 04 40 80 00       	mov    0x804004,%eax
  801b76:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7c:	5b                   	pop    %ebx
  801b7d:	5e                   	pop    %esi
  801b7e:	5f                   	pop    %edi
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    

00801b81 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	57                   	push   %edi
  801b85:	56                   	push   %esi
  801b86:	53                   	push   %ebx
  801b87:	83 ec 0c             	sub    $0xc,%esp
  801b8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801b93:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801b95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b9a:	0f 44 d8             	cmove  %eax,%ebx
  801b9d:	eb 1c                	jmp    801bbb <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801b9f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ba2:	74 12                	je     801bb6 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801ba4:	50                   	push   %eax
  801ba5:	68 28 23 80 00       	push   $0x802328
  801baa:	6a 4e                	push   $0x4e
  801bac:	68 35 23 80 00       	push   $0x802335
  801bb1:	e8 a5 f8 ff ff       	call   80145b <_panic>
		sys_yield();
  801bb6:	e8 a0 e9 ff ff       	call   80055b <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801bbb:	ff 75 14             	pushl  0x14(%ebp)
  801bbe:	53                   	push   %ebx
  801bbf:	56                   	push   %esi
  801bc0:	57                   	push   %edi
  801bc1:	e8 41 eb ff ff       	call   800707 <sys_ipc_try_send>
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	78 d2                	js     801b9f <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801bcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd0:	5b                   	pop    %ebx
  801bd1:	5e                   	pop    %esi
  801bd2:	5f                   	pop    %edi
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    

00801bd5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bdb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801be0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801be3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801be9:	8b 52 50             	mov    0x50(%edx),%edx
  801bec:	39 ca                	cmp    %ecx,%edx
  801bee:	75 0d                	jne    801bfd <ipc_find_env+0x28>
			return envs[i].env_id;
  801bf0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bf3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bf8:	8b 40 48             	mov    0x48(%eax),%eax
  801bfb:	eb 0f                	jmp    801c0c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bfd:	83 c0 01             	add    $0x1,%eax
  801c00:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c05:	75 d9                	jne    801be0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c0c:	5d                   	pop    %ebp
  801c0d:	c3                   	ret    

00801c0e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c14:	89 d0                	mov    %edx,%eax
  801c16:	c1 e8 16             	shr    $0x16,%eax
  801c19:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c20:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c25:	f6 c1 01             	test   $0x1,%cl
  801c28:	74 1d                	je     801c47 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c2a:	c1 ea 0c             	shr    $0xc,%edx
  801c2d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c34:	f6 c2 01             	test   $0x1,%dl
  801c37:	74 0e                	je     801c47 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c39:	c1 ea 0c             	shr    $0xc,%edx
  801c3c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c43:	ef 
  801c44:	0f b7 c0             	movzwl %ax,%eax
}
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    
  801c49:	66 90                	xchg   %ax,%ax
  801c4b:	66 90                	xchg   %ax,%ax
  801c4d:	66 90                	xchg   %ax,%ax
  801c4f:	90                   	nop

00801c50 <__udivdi3>:
  801c50:	55                   	push   %ebp
  801c51:	57                   	push   %edi
  801c52:	56                   	push   %esi
  801c53:	53                   	push   %ebx
  801c54:	83 ec 1c             	sub    $0x1c,%esp
  801c57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c67:	85 f6                	test   %esi,%esi
  801c69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c6d:	89 ca                	mov    %ecx,%edx
  801c6f:	89 f8                	mov    %edi,%eax
  801c71:	75 3d                	jne    801cb0 <__udivdi3+0x60>
  801c73:	39 cf                	cmp    %ecx,%edi
  801c75:	0f 87 c5 00 00 00    	ja     801d40 <__udivdi3+0xf0>
  801c7b:	85 ff                	test   %edi,%edi
  801c7d:	89 fd                	mov    %edi,%ebp
  801c7f:	75 0b                	jne    801c8c <__udivdi3+0x3c>
  801c81:	b8 01 00 00 00       	mov    $0x1,%eax
  801c86:	31 d2                	xor    %edx,%edx
  801c88:	f7 f7                	div    %edi
  801c8a:	89 c5                	mov    %eax,%ebp
  801c8c:	89 c8                	mov    %ecx,%eax
  801c8e:	31 d2                	xor    %edx,%edx
  801c90:	f7 f5                	div    %ebp
  801c92:	89 c1                	mov    %eax,%ecx
  801c94:	89 d8                	mov    %ebx,%eax
  801c96:	89 cf                	mov    %ecx,%edi
  801c98:	f7 f5                	div    %ebp
  801c9a:	89 c3                	mov    %eax,%ebx
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
  801cb0:	39 ce                	cmp    %ecx,%esi
  801cb2:	77 74                	ja     801d28 <__udivdi3+0xd8>
  801cb4:	0f bd fe             	bsr    %esi,%edi
  801cb7:	83 f7 1f             	xor    $0x1f,%edi
  801cba:	0f 84 98 00 00 00    	je     801d58 <__udivdi3+0x108>
  801cc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	89 c5                	mov    %eax,%ebp
  801cc9:	29 fb                	sub    %edi,%ebx
  801ccb:	d3 e6                	shl    %cl,%esi
  801ccd:	89 d9                	mov    %ebx,%ecx
  801ccf:	d3 ed                	shr    %cl,%ebp
  801cd1:	89 f9                	mov    %edi,%ecx
  801cd3:	d3 e0                	shl    %cl,%eax
  801cd5:	09 ee                	or     %ebp,%esi
  801cd7:	89 d9                	mov    %ebx,%ecx
  801cd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cdd:	89 d5                	mov    %edx,%ebp
  801cdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ce3:	d3 ed                	shr    %cl,%ebp
  801ce5:	89 f9                	mov    %edi,%ecx
  801ce7:	d3 e2                	shl    %cl,%edx
  801ce9:	89 d9                	mov    %ebx,%ecx
  801ceb:	d3 e8                	shr    %cl,%eax
  801ced:	09 c2                	or     %eax,%edx
  801cef:	89 d0                	mov    %edx,%eax
  801cf1:	89 ea                	mov    %ebp,%edx
  801cf3:	f7 f6                	div    %esi
  801cf5:	89 d5                	mov    %edx,%ebp
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	f7 64 24 0c          	mull   0xc(%esp)
  801cfd:	39 d5                	cmp    %edx,%ebp
  801cff:	72 10                	jb     801d11 <__udivdi3+0xc1>
  801d01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d05:	89 f9                	mov    %edi,%ecx
  801d07:	d3 e6                	shl    %cl,%esi
  801d09:	39 c6                	cmp    %eax,%esi
  801d0b:	73 07                	jae    801d14 <__udivdi3+0xc4>
  801d0d:	39 d5                	cmp    %edx,%ebp
  801d0f:	75 03                	jne    801d14 <__udivdi3+0xc4>
  801d11:	83 eb 01             	sub    $0x1,%ebx
  801d14:	31 ff                	xor    %edi,%edi
  801d16:	89 d8                	mov    %ebx,%eax
  801d18:	89 fa                	mov    %edi,%edx
  801d1a:	83 c4 1c             	add    $0x1c,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
  801d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d28:	31 ff                	xor    %edi,%edi
  801d2a:	31 db                	xor    %ebx,%ebx
  801d2c:	89 d8                	mov    %ebx,%eax
  801d2e:	89 fa                	mov    %edi,%edx
  801d30:	83 c4 1c             	add    $0x1c,%esp
  801d33:	5b                   	pop    %ebx
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    
  801d38:	90                   	nop
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	89 d8                	mov    %ebx,%eax
  801d42:	f7 f7                	div    %edi
  801d44:	31 ff                	xor    %edi,%edi
  801d46:	89 c3                	mov    %eax,%ebx
  801d48:	89 d8                	mov    %ebx,%eax
  801d4a:	89 fa                	mov    %edi,%edx
  801d4c:	83 c4 1c             	add    $0x1c,%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5e                   	pop    %esi
  801d51:	5f                   	pop    %edi
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    
  801d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d58:	39 ce                	cmp    %ecx,%esi
  801d5a:	72 0c                	jb     801d68 <__udivdi3+0x118>
  801d5c:	31 db                	xor    %ebx,%ebx
  801d5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d62:	0f 87 34 ff ff ff    	ja     801c9c <__udivdi3+0x4c>
  801d68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d6d:	e9 2a ff ff ff       	jmp    801c9c <__udivdi3+0x4c>
  801d72:	66 90                	xchg   %ax,%ax
  801d74:	66 90                	xchg   %ax,%ax
  801d76:	66 90                	xchg   %ax,%ax
  801d78:	66 90                	xchg   %ax,%ax
  801d7a:	66 90                	xchg   %ax,%ax
  801d7c:	66 90                	xchg   %ax,%ax
  801d7e:	66 90                	xchg   %ax,%ax

00801d80 <__umoddi3>:
  801d80:	55                   	push   %ebp
  801d81:	57                   	push   %edi
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
  801d84:	83 ec 1c             	sub    $0x1c,%esp
  801d87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d97:	85 d2                	test   %edx,%edx
  801d99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801da1:	89 f3                	mov    %esi,%ebx
  801da3:	89 3c 24             	mov    %edi,(%esp)
  801da6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801daa:	75 1c                	jne    801dc8 <__umoddi3+0x48>
  801dac:	39 f7                	cmp    %esi,%edi
  801dae:	76 50                	jbe    801e00 <__umoddi3+0x80>
  801db0:	89 c8                	mov    %ecx,%eax
  801db2:	89 f2                	mov    %esi,%edx
  801db4:	f7 f7                	div    %edi
  801db6:	89 d0                	mov    %edx,%eax
  801db8:	31 d2                	xor    %edx,%edx
  801dba:	83 c4 1c             	add    $0x1c,%esp
  801dbd:	5b                   	pop    %ebx
  801dbe:	5e                   	pop    %esi
  801dbf:	5f                   	pop    %edi
  801dc0:	5d                   	pop    %ebp
  801dc1:	c3                   	ret    
  801dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dc8:	39 f2                	cmp    %esi,%edx
  801dca:	89 d0                	mov    %edx,%eax
  801dcc:	77 52                	ja     801e20 <__umoddi3+0xa0>
  801dce:	0f bd ea             	bsr    %edx,%ebp
  801dd1:	83 f5 1f             	xor    $0x1f,%ebp
  801dd4:	75 5a                	jne    801e30 <__umoddi3+0xb0>
  801dd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dda:	0f 82 e0 00 00 00    	jb     801ec0 <__umoddi3+0x140>
  801de0:	39 0c 24             	cmp    %ecx,(%esp)
  801de3:	0f 86 d7 00 00 00    	jbe    801ec0 <__umoddi3+0x140>
  801de9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ded:	8b 54 24 04          	mov    0x4(%esp),%edx
  801df1:	83 c4 1c             	add    $0x1c,%esp
  801df4:	5b                   	pop    %ebx
  801df5:	5e                   	pop    %esi
  801df6:	5f                   	pop    %edi
  801df7:	5d                   	pop    %ebp
  801df8:	c3                   	ret    
  801df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e00:	85 ff                	test   %edi,%edi
  801e02:	89 fd                	mov    %edi,%ebp
  801e04:	75 0b                	jne    801e11 <__umoddi3+0x91>
  801e06:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0b:	31 d2                	xor    %edx,%edx
  801e0d:	f7 f7                	div    %edi
  801e0f:	89 c5                	mov    %eax,%ebp
  801e11:	89 f0                	mov    %esi,%eax
  801e13:	31 d2                	xor    %edx,%edx
  801e15:	f7 f5                	div    %ebp
  801e17:	89 c8                	mov    %ecx,%eax
  801e19:	f7 f5                	div    %ebp
  801e1b:	89 d0                	mov    %edx,%eax
  801e1d:	eb 99                	jmp    801db8 <__umoddi3+0x38>
  801e1f:	90                   	nop
  801e20:	89 c8                	mov    %ecx,%eax
  801e22:	89 f2                	mov    %esi,%edx
  801e24:	83 c4 1c             	add    $0x1c,%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5f                   	pop    %edi
  801e2a:	5d                   	pop    %ebp
  801e2b:	c3                   	ret    
  801e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e30:	8b 34 24             	mov    (%esp),%esi
  801e33:	bf 20 00 00 00       	mov    $0x20,%edi
  801e38:	89 e9                	mov    %ebp,%ecx
  801e3a:	29 ef                	sub    %ebp,%edi
  801e3c:	d3 e0                	shl    %cl,%eax
  801e3e:	89 f9                	mov    %edi,%ecx
  801e40:	89 f2                	mov    %esi,%edx
  801e42:	d3 ea                	shr    %cl,%edx
  801e44:	89 e9                	mov    %ebp,%ecx
  801e46:	09 c2                	or     %eax,%edx
  801e48:	89 d8                	mov    %ebx,%eax
  801e4a:	89 14 24             	mov    %edx,(%esp)
  801e4d:	89 f2                	mov    %esi,%edx
  801e4f:	d3 e2                	shl    %cl,%edx
  801e51:	89 f9                	mov    %edi,%ecx
  801e53:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e5b:	d3 e8                	shr    %cl,%eax
  801e5d:	89 e9                	mov    %ebp,%ecx
  801e5f:	89 c6                	mov    %eax,%esi
  801e61:	d3 e3                	shl    %cl,%ebx
  801e63:	89 f9                	mov    %edi,%ecx
  801e65:	89 d0                	mov    %edx,%eax
  801e67:	d3 e8                	shr    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	09 d8                	or     %ebx,%eax
  801e6d:	89 d3                	mov    %edx,%ebx
  801e6f:	89 f2                	mov    %esi,%edx
  801e71:	f7 34 24             	divl   (%esp)
  801e74:	89 d6                	mov    %edx,%esi
  801e76:	d3 e3                	shl    %cl,%ebx
  801e78:	f7 64 24 04          	mull   0x4(%esp)
  801e7c:	39 d6                	cmp    %edx,%esi
  801e7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e82:	89 d1                	mov    %edx,%ecx
  801e84:	89 c3                	mov    %eax,%ebx
  801e86:	72 08                	jb     801e90 <__umoddi3+0x110>
  801e88:	75 11                	jne    801e9b <__umoddi3+0x11b>
  801e8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e8e:	73 0b                	jae    801e9b <__umoddi3+0x11b>
  801e90:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e94:	1b 14 24             	sbb    (%esp),%edx
  801e97:	89 d1                	mov    %edx,%ecx
  801e99:	89 c3                	mov    %eax,%ebx
  801e9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e9f:	29 da                	sub    %ebx,%edx
  801ea1:	19 ce                	sbb    %ecx,%esi
  801ea3:	89 f9                	mov    %edi,%ecx
  801ea5:	89 f0                	mov    %esi,%eax
  801ea7:	d3 e0                	shl    %cl,%eax
  801ea9:	89 e9                	mov    %ebp,%ecx
  801eab:	d3 ea                	shr    %cl,%edx
  801ead:	89 e9                	mov    %ebp,%ecx
  801eaf:	d3 ee                	shr    %cl,%esi
  801eb1:	09 d0                	or     %edx,%eax
  801eb3:	89 f2                	mov    %esi,%edx
  801eb5:	83 c4 1c             	add    $0x1c,%esp
  801eb8:	5b                   	pop    %ebx
  801eb9:	5e                   	pop    %esi
  801eba:	5f                   	pop    %edi
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    
  801ebd:	8d 76 00             	lea    0x0(%esi),%esi
  801ec0:	29 f9                	sub    %edi,%ecx
  801ec2:	19 d6                	sbb    %edx,%esi
  801ec4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ec8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ecc:	e9 18 ff ff ff       	jmp    801de9 <__umoddi3+0x69>
