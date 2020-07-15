
Name:       gcc-ilp32
Version:    10.0.1
Release:    DATESTRING%{?dist}
Summary:    Marvell's Release of GCC-ILP32 10.0.1
BuildArch:  aarch64
License:    GNU GPL 3.0
URL:        https://github.com/MarvellServer/ThunderX-Toolchain-gcc-ilp32.git
Source0:    /tmp/%{name}-%{version}.tar.gz

Requires:   gcc, libgcc, python3-devel, binutils-devel, ncurses-devel

%define __requires_exclude libgcc_s.so.1
%define debug_package %{nil}

%description
GNU Compiler Collection, ILP32 Release

%prep
tar -xzvf /tmp/%{name}-%{version}.tar.gz -C ${RPM_SOURCE_DIR}/

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/
cp -a $RPM_SOURCE_DIR/opt $RPM_BUILD_ROOT/

%files
/opt

%changelog
* Tue Jul 14 2020 Srikanth Yalavarthi <syalavarthi@marvell.com>
- converted as generic template

* Tue Jun 9 2020 Wei Zhao <wxz@marvell.com>
- First release of marvell gcc ilp32 RPM
