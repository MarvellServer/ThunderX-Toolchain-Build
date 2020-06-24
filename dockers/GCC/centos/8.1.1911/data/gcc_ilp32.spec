Name:       gcc-tot-ilp32
Version:    REPLACE_TODAY
Release:    0%{?dist}
Summary:    Marvell's Release of gcc ilp32 1.0
BuildArch:  aarch64
License:    GNU GPL 3.0
URL:        https://github.com/MarvellServer/ThunderX-Toolchain-gcc-ilp32.git
Source0:    https://github.com/MarvellServer/ThunderX-Toolchain-gcc-ilp32.git

Requires:   gcc >= 8.3.0, libgcc, python3-devel, binutils-devel, ncurses-devel 

%define __requires_exclude libgcc_s.so.1
%define debug_package %{nil}

%description
gcc tot ilp32 build for TXOS

%prep
tar -xvf $RPM_SOURCE_DIR/%{name}.tar.gz -C $RPM_BUILD_DIR/

%build
#nothing required

%install
mkdir -p %{buildroot}/opt
cp -r * %{buildroot}/opt

%files
/opt

%changelog
* Tue Jun 9 2020 Wei Zhao <wxz@marvell.com>
- First release of marvell gcc ilp32 RPM

