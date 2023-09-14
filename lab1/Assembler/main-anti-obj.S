
main.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
   0:	f3 0f 1e fa          	endbr64 
   4:	55                   	push   %rbp
   5:	48 89 e5             	mov    %rsp,%rbp
   8:	48 83 ec 20          	sub    $0x20,%rsp
   c:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
  13:	00 00 
  15:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
  19:	31 c0                	xor    %eax,%eax
  1b:	48 8d 45 ec          	lea    -0x14(%rbp),%rax
  1f:	48 89 c6             	mov    %rax,%rsi
  22:	48 8d 05 00 00 00 00 	lea    0x0(%rip),%rax        # 29 <main+0x29>
  29:	48 89 c7             	mov    %rax,%rdi
  2c:	b8 00 00 00 00       	mov    $0x0,%eax
  31:	e8 00 00 00 00       	call   36 <main+0x36>
  36:	c7 45 f0 02 00 00 00 	movl   $0x2,-0x10(%rbp)
  3d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%rbp)
  44:	eb 0e                	jmp    54 <main+0x54>
  46:	8b 45 f4             	mov    -0xc(%rbp),%eax
  49:	0f af 45 f0          	imul   -0x10(%rbp),%eax
  4d:	89 45 f4             	mov    %eax,-0xc(%rbp)
  50:	83 45 f0 01          	addl   $0x1,-0x10(%rbp)
  54:	8b 45 ec             	mov    -0x14(%rbp),%eax
  57:	39 45 f0             	cmp    %eax,-0x10(%rbp)
  5a:	7e ea                	jle    46 <main+0x46>
  5c:	8b 45 f4             	mov    -0xc(%rbp),%eax
  5f:	89 c6                	mov    %eax,%esi
  61:	48 8d 05 00 00 00 00 	lea    0x0(%rip),%rax        # 68 <main+0x68>
  68:	48 89 c7             	mov    %rax,%rdi
  6b:	b8 00 00 00 00       	mov    $0x0,%eax
  70:	e8 00 00 00 00       	call   75 <main+0x75>
  75:	b8 00 00 00 00       	mov    $0x0,%eax
  7a:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  7e:	64 48 2b 14 25 28 00 	sub    %fs:0x28,%rdx
  85:	00 00 
  87:	74 05                	je     8e <main+0x8e>
  89:	e8 00 00 00 00       	call   8e <main+0x8e>
  8e:	c9                   	leave  
  8f:	c3                   	ret    
