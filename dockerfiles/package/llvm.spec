
Name:       llvm
Version:    TOOLCHAIN_VERSION
Release:    DATESTRING%{?dist}
Summary:    LLVM Upstream Release
BuildArch:  aarch64
License:    Apache 2.0
URL:        git@github.com:llvm/llvm-project.git
Source0:    /tmp/%{name}-%{version}.tar.gz

Requires:  gcc, gcc-c++, gcc-gfortran, cmake, git, bison, gawk, rsync, python3-devel, libxml2-devel, libedit-devel, swig, libffi-devel, binutils-devel, ncurses-devel 

%define debug_package %{nil}

%description
LLVM Upstream Release with Clang

%prep
tar -xzvf /tmp/%{name}-%{version}.tar.gz -C ${RPM_SOURCE_DIR}/

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/
cp -a $RPM_SOURCE_DIR/opt $RPM_BUILD_ROOT/
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/TOOLCHAIN_VERSION/share/opt-viewer/opt-diff.py
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/TOOLCHAIN_VERSION/share/opt-viewer/opt-stats.py
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/TOOLCHAIN_VERSION/share/opt-viewer/optrecord.py
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/TOOLCHAIN_VERSION/share/opt-viewer/opt-viewer.py
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/TOOLCHAIN_VERSION/bin/git-clang-format
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/TOOLCHAIN_VERSION/bin/hmaptool
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/TOOLCHAIN_VERSION/bin/scan-view
sed -i '1s/python/python3/' $RPM_BUILD_ROOT/opt/llvm/TOOLCHAIN_VERSION/share/clang/clang-format-diff.py

%files
/opt

%changelog
* Tue Jul 14 2020 Srikanth Yalavarthi <syalavarthi@marvell.com> - 9.0.0-20200714
- added LLVM template
