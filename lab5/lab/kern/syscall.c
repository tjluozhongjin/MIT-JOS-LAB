/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
// ?????
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	//user_mem_assert(curenv, s, len, 0);
	//检查用户传送过来的指针
	user_mem_assert(curenv, s, len, PTE_U | PTE_P);	

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	env_destroy(e);
	return 0;
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
// 创建1个新的空白进程
static envid_t
sys_exofork(void)
{
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	//panic("sys_exofork not implemented");

	struct Env *e;
	// 申请一个新进程
	int ret = env_alloc(&e, curenv->env_id);
	if (ret < 0) 
		return ret;
	
	// 初始化新进程
	e->env_status = ENV_NOT_RUNNABLE;
	e->env_tf = curenv->env_tf;
	// 将子进程的返回值设置为0
	e->env_tf.tf_regs.reg_eax = 0;

	return e->env_id;
}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
// 设置进程的状态
static int
sys_env_set_status(envid_t envid, int status)
{
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e;
	int ret;

	if ((ret = envid2env(envid, &e, 1)) < 0)
		return ret;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;

	e->env_status = status;

	return 0;
	//panic("sys_env_set_status not implemented");
}

// Set envid's trap frame to 'tf'.
// tf is modified to make sure that user environments always run at code
// protection level 3 (CPL 3) with interrupts enabled.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
// 初始化新建进程的寄存器信息
static int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *env;
	if (envid2env(envid, &env, 1) < 0)
		return -E_BAD_ENV;

 	// if (tf->tf_eip >= UTOP)
 	// 	return 
 	env->env_tf = *tf;
 	env->env_tf.tf_eflags |= FL_IF;

	return 0;
	panic("sys_env_set_trapframe not implemented");
	//panic("sys_env_set_trapframe not implemented");
}

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
// 将用户态的页错误处理函数注册到进程结构中
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	//panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *e;
	int ret;
	
	if ((ret = envid2env(envid, &e, 1)) < 0)
		return ret;

	e->env_pgfault_upcall = func;
	return 0;
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.  See PTE_SYSCALL in inc/mmu.h.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
// 分配1个物理页并映射到给定进程的进程空间的指定虚拟地址
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env *e;
	struct PageInfo *pp;
	int ret;

	//cprintf("id:--------%d\n",envid);

	if ((ret = envid2env(envid, &e, 1)) < 0)
		return ret;

	if (va >= (void *)UTOP || PGOFF(va) != 0)
		return -E_INVAL;

	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
		return -E_INVAL;

	// 申请一个物理页
	if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
		return -E_NO_MEM;
	
	// 映射物理页到进程的虚拟空间中
	if ((ret = page_insert(e->env_pgdir, pp, va, perm)) < 0) {
		page_free(pp);
		return ret;
	}

	return 0;
	//panic("sys_page_alloc not implemented");
}

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
// 从1个进程的页表中拷贝1个页映射到另1个进程的页表中
// 复制一个页映射
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	//panic("sys_page_map not implemented");
	struct Env *srcenv, *dstenv;
	struct PageInfo *pp;
	pte_t *pte;
	int ret;
	
	if ((ret = envid2env(srcenvid, &srcenv, 1)) < 0)
		return ret;
	if ((ret = envid2env(dstenvid, &dstenv, 1)) < 0)
		return ret;

	if (srcva >= (void *) UTOP || PGOFF(srcva) != 0)
		return -E_INVAL;
	if (dstva >= (void *) UTOP || PGOFF(dstva) != 0)
		return -E_INVAL;
	
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
		return -E_INVAL;
	
	// 查到进程 srcenv 的虚拟地址srcva对应的物理页
	if ((pp = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
		return -E_INVAL;

	if ((perm & PTE_W) && !(*pte & PTE_W))
		return -E_INVAL;
	
	
	// 将进程虚拟地址 dstva 对应的虚拟页映射到物理页pp 
	if ((ret = page_insert(dstenv->env_pgdir, pp, dstva, perm)) < 0)
		return ret;
	
	return 0;
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
// 解除进程 envid 虚拟地址 va 对应的页映射
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	//panic("sys_page_unmap not implemented");
	struct Env* e;
	int ret;

	if ((ret = envid2env(envid, &e, 1)) < 0)
		return ret;

	if (va >= (void *) UTOP || PGOFF(va) != 0)
		return -E_INVAL;
	
	// 解除映射
	page_remove(e->env_pgdir, va);

	return 0;
}

// Try to send 'value' to the target env 'envid'.
// If srcva < UTOP, then also send page currently mapped at 'srcva',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target is not blocked, waiting for an IPC.
//
// The send also can fail for the other reasons listed below.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused sys_ipc_recv system call.  (Hint: does the
// sys_ipc_recv function ever actually return?)
//
// If the sender wants to send a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc only happens when no errors occur.
//
// Returns 0 on success, < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
// 此处将页传送页字传送混合一起了
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");
	struct Env *env;
	int r;
	if ((r = envid2env(envid, &env, 0)) < 0)
		return -E_BAD_ENV;
	if (env->env_ipc_recving == 0)
		return -E_IPC_NOT_RECV;
	if (srcva < (void *) UTOP) {
		// int flag = PTE_U | PTE_P;
		// if ((perm & flag) != flag)
		// 	return -E_INVAL;

		// if (perm & (~(PTE_U | PTE_P | PTE_AVAIL | PTE_W)))
		// 	return -E_INVAL;

		if (srcva != ROUNDDOWN(srcva, PGSIZE))
			return -E_INVAL;
		
		// 根据发送者(当前进程)提供的虚拟地址找到对应的物理页，再将该物理页映射到接受者的虚拟空间

		pte_t *pte;
		// 1.根据发送者提供的虚拟地址查找发送内容所在的物理页
		struct PageInfo *page = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!page)
			return -E_INVAL;

		if((perm & PTE_U) == 0 || (perm & PTE_P) == 0 || (perm & ~PTE_SYSCALL) != 0)
            return -E_INVAL;

		if ((perm & PTE_W) && !(*pte & PTE_W))
			return -E_INVAL;
		// 2.将物理页映射到接受者的虚拟空间中
		if (env->env_ipc_dstva < (void *) UTOP) {
			if ((r = page_insert(env->env_pgdir, page, env->env_ipc_dstva, perm)) < 0)
				return -E_NO_MEM;
			env->env_ipc_perm = perm;
		}
	}
	// 3.更新接受者的信息，通知其消息已经发送
	env->env_ipc_recving = 0;
	env->env_ipc_from = curenv->env_id;
	env->env_ipc_value = value;
	// 将接受进程设置为ENV_RUNNABLE，使得其可以重新参与调度
	env->env_status = ENV_RUNNABLE;
	// ???
	env->env_tf.tf_regs.reg_eax = 0;
	return 0;
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
// 提供一页用于接受信息
// 参数为接受消息的虚拟页的起始地址
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if (dstva < (void *) UTOP && dstva != ROUNDDOWN(dstva, PGSIZE))
		return -E_INVAL;
	
	curenv->env_ipc_recving = 1;
	curenv->env_ipc_dstva = dstva;
	// 设置当前进程为
	curenv->env_status = ENV_NOT_RUNNABLE;
	sys_yield();

	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *) a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_env_destroy:
		return sys_env_destroy(a1);
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_yield:
		sys_yield();
		return 0;
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *) a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *) a2, a3, (void *) a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *) a2);
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *) a2);	
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *) a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *) a1);
	case SYS_env_set_trapframe:
		return sys_env_set_trapframe(a1, (struct Trapframe *) a2);
	default:
		return -E_INVAL;
	}
	panic("syscall not implemented");
}

