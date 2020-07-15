
Name:       llvm
Version:    9.0.0
Release:    DATESTRING%{?dist}
Summary:    Marvell's Release of LLVM 9.0.0
BuildArch:  aarch64
License:    Apache 2.0
URL:        git@github.com:MarvellServer/ThunderX-Toolchain-CT-FLANG.git
Source0:    /tmp/%{name}-%{version}.tar.gz

Requires:  gcc, gcc-c++, gcc-gfortran, cmake, git, bison, gawk, rsync, python3-devel, libxml2-devel, libedit-devel, swig, libffi-devel, binutils-devel, ncurses-devel 

%define debug_package %{nil}

%description
The LLVM Compiler Infrastructure

%prep
tar -xzvf /tmp/%{name}-%{version}.tar.gz -C ${RPM_SOURCE_DIR}/

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/
cp -a $RPM_SOURCE_DIR/opt $RPM_BUILD_ROOT/
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/9.0.0/share/opt-viewer/opt-diff.py
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/9.0.0/share/opt-viewer/opt-stats.py
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/9.0.0/share/opt-viewer/optrecord.py
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/9.0.0/share/opt-viewer/opt-viewer.py
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/9.0.0/bin/git-clang-format
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/9.0.0/bin/hmaptool
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/9.0.0/bin/scan-view
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/9.0.0/share/clang/clang-format-diff.py

%files
/opt

%changelog
* Tue Jul 14 2020 Srikanth Yalavarthi <syalavarthi@marvell.com> - 9.0.0-20200714
- converted as generic template

* Wed Jun 24 2020 Srikanth Yalavarthi <syalavarthi@marvell.com> - 9.0.0-20200624
- llvm ctt_latest_release dated 2020-06-22
