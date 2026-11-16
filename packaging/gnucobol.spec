Name:           gnucobol
Version:        %{gnucobol_version}
Release:        %{?gnucobol_release}%{!?gnucobol_release:ZWIEGNET.1}
Summary:        GNU COBOL compiler and runtime
License:        GPL-3.0-or-later
URL:            https://gnucobol.sourceforge.io/
Source0:        %{name}-%{version}.tar.gz
BuildRequires:  gcc
BuildRequires:  make
BuildRequires:  ncurses-devel
BuildRequires:  gmp-devel

%description
GnuCOBOL is a COBOL compiler that translates COBOL source into C and uses
the system C compiler to produce native executables. This package includes
the compiler and its runtime library.

%prep
%setup -q -n gnucobol

%build
%configure --disable-static
%make_build

%check
%make_build check

%install
%make_install

# Capture the complete installed file list without claiming unrelated system files.
find %{buildroot} -type f -o -type l | sed 's#^%{buildroot}##' | sort > %{_builddir}/gnucobol-filelist

%files -f %{_builddir}/gnucobol-filelist
%license COPYING
