
# define date
%define build_timestamp %(date +"%Y%m%d")

Name:       gcc-ilp32
Version:    10.0.0
Release:    %{build_timestamp}%{?dist}
Summary:    Marvell's Release of gcc ilp32 1.0
BuildArch:  aarch64
License:    GNU GPL 3.0
URL:        https://github.com/MarvellServer/ThunderX-Toolchain-gcc-ilp32.git
Source0:    /tmp/gcc-%{version}.tar.gz

Requires:   gcc, libgcc, python3-devel, binutils-devel, ncurses-devel 

%define __requires_exclude libgcc_s.so.1
%define debug_package %{nil}

%description
gcc tot ilp32 build for TXOS

%prep
#tar -xzvf /tmp/%{name}-%{version}.tar.gz -C ${RPM_SOURCE_DIR}/
tar -xzvf /tmp/gcc-%{version}.tar.gz -C ${RPM_SOURCE_DIR}/

%build
#nothing required

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/
cp -a $RPM_SOURCE_DIR/opt $RPM_BUILD_ROOT/

%files
/opt

%changelog
* Tue Jun 9 2020 Wei Zhao <wxz@marvell.com>
- First release of marvell gcc ilp32 RPM

