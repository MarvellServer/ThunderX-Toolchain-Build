### ThunderX-Toolchain-Build

The "devel" branch hosts template dockerfiles, used to build GCC-ILP32, LLVM and FLANG toolchains.


**Source Code for GCC-ILP32 Toolchain**

GCC-ILP32 : https://github.com/MarvellServer/ThunderX-Toolchain-gcc-ilp32

GLIBC-ILP32: https://github.com/MarvellServer/ThunderX-Toolchain-glibc-ilp32

LINUX KERNEL: https://github.com/MarvellServer/ThunderX-ilp32-linux

BINUTILS: http://sourceware.org/git/binutils-gdb.git

**Source Code for LLVM Toolchain**

LLVM : https://github.com/llvm/llvm-project

**Source Code for FLANG Toolchain**

LLVM : https://github.com/MarvellServer/ThunderX-Toolchain-CT-LLVM-9

FLANG: https://github.com/MarvellServer/ThunderX-Toolchain-CT-FLANG

OpenMP, PGMATH, LLDB : https://github.com/llvm/llvm-project.git

FLANG-DRIVER: https://github.com/flang-compiler/flang-driver.git

**Build:**
build.sh is the driver script used to build the toolchains. build.sh used "config" file to define the build environment. Variables that control the build process.

TOOLCHAIN_NAME : gcc-ilp32 / llvm / flang

TOOLCHAIN_VERSION : Toochain version string

DISTRO_NAME: centos/ubuntu

DISTRO_VERSION: OS version string

GCC_BRANCH : GCC Git Branch to be built (Only for GCC build)

LLVM_BRANCH : LLVM Git Branch to be built (Only for LLVM build)

FLANG_BRANCH : FLANG Git Branch to be built (Only for FLANG build)

PACKAGE_NAME : Name of the (deb/rpm) to be created (Optional). Defaults to TOOLCHAIN_NAME if not defined

APP : Application to be built

"build.sh" generates the dockerfile required to build the toolchain  and the test application from the template dockerfiles. The toolchain binaries (RPM/DEB ) are created in the corresponding directories within the temporary top-level "dockerfiles/build" folder.

Additional files needed to checkout the git repositories like "github_rsa", "ssh_config" and application specific files should be placed in temporary "dockerfiles/extras" folder. These files are not part of the repository.

Tested Builds:

 - GCC-ILP32: Ubuntu 20.04, Ubuntu 18.04, CentOS 8.1.1911
 - LLVM: Ubuntu 20.04, Ubuntu 18.04, CentOS 8.1.1911
 - FLANG: Ubuntu 20.04, Ubuntu 18.04, CentOS 8.1.1911
 
 
**ssh_config**


    user@localhost:~/ThunderX-Toolchain-Build/dockerfiles$ cat extras/ssh_config
    Host github.com
        HostName github.com
        User user
        IdentityFile ~/.ssh/github_rsa
        StrictHostKeyChecking=no
