Name:       flang-9.0.1-tx3
Version:    REPLACE_TODAY
Release:    0%{?dist}
Summary:    Marvell's Release of FLANG 9.0.1 with tx3
BuildArch:  aarch64
License:    Apache 2.0
URL:        https://github.com/MarvellServer/ThunderX-Toolchain-flang9
Source0:    http://socrates/Server Toolchain/flang/%{name}-%{version}.tar.gz

Requires:  gcc, gcc-c++, gcc-gfortran, cmake, git, bison, gawk, rsync, python3-devel, libxml2-devel, libedit-devel, swig, libffi-devel, binutils-devel, ncurses-devel

%define debug_package %{nil}

%description
The LLVM Compiler Infrastructure

%prep
tar -xvf $RPM_SOURCE_DIR/%{name}-%{version}.tar.gz -C $RPM_BUILD_DIR/

%build
#nothing required

%install
mkdir -p %{buildroot}/opt
cp -r * %{buildroot}/opt

%files
/opt

%changelog
* Thu May 21 2020 Wei Zhao <wxz@marvell.com> Srikanth Yalavarthi <syalavarthi@marvell.com> - 10.0.1
- First release of marvell flang RPM
