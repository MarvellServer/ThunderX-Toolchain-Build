### ThunderX-Toolchain-Build

The "master" branch contains dockerfiles and scripts used to build LLVM and GCC-ILP32 toolchains. The dockerfiles are organized as below.

```
|─── gcc-ilp32
│    ├─── scripts
│    └─── dockerfiles
│         ├─── centos
|         |    └─── 8.1.1911
|         |          ├─── Dockerfile
|         |          └─── data/gcc-ilp32.spec
│         └─── ubuntu
|              └─── 20.04/Dockerfile
|                    ├─── Dockerfile
|                    └─── data/control
|─── llvm
|    ├─── scripts
|    └─── dockerfiles
|         ├─── centos
|         |    └─── 8.1.1911
|         |          ├─── Dockerfile
|         |          └─── data/llvm.spec
|         └─── ubuntu
|              └─── 20.04/Dockerfile
|                    ├─── Dockerfile
|                    |─── data/control
|                    └─── llvm
└─── flang
     ├─── scripts
     └─── dockerfiles
          ├─── centos
          |    └─── 8.1.1911
          |          ├─── Dockerfile
          |          └─── data/llvm.spec
          └─── ubuntu
               └─── 20.04/Dockerfile
                     ├─── Dockerfile
                     └─── data/control
```

**Source Code for GCC-ILP32 Toolchain**

GCC-ILP32 : https://github.com/MarvellServer/ThunderX-Toolchain-gcc-ilp32

GLIBC-ILP32: https://github.com/MarvellServer/ThunderX-Toolchain-glibc-ilp32

LINUX KERNEL: https://github.com/MarvellServer/ThunderX-ilp32-linux

BINUTILS: http://sourceware.org/git/binutils-gdb.git

**Source Code for FLANG Toolchain**

LLVM : https://github.com/llvm/llvm-project

**Source Code for FLANG Toolchain**

LLVM : https://github.com/MarvellServer/ThunderX-Toolchain-CT-LLVM-9

FLANG: https://github.com/MarvellServer/ThunderX-Toolchain-CT-FLANG

OpenMP, PGMATH, LLDB : https://github.com/llvm/llvm-project.git

FLANG-DRIVER: https://github.com/flang-compiler/flang-driver.git

**Build:**

Docker images can build using the specific dockerfiles with  build.sh

Additional files needed to checkout the git repositories like "github_rsa", "ssh_config" and application specific files should be placed in data folder. These files are not part of the repository.

