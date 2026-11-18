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
# Do not bake RPM-only GCC specs (redhat-hardened-cc1, annobin, package-notes)
# into GnuCOBOL's installed COB_CFLAGS.  Those specs are intended for RPM
# builds and can require RPM_ARCH when users compile COBOL programs later.
# Configure with portable flags, then apply the full EL build flags to the
# package build itself.
CFLAGS="-O2" %configure --disable-static --without-db
%make_build CFLAGS="%{optflags} -Wno-cpp"

%check
# The curses tests need a real terminfo entry in the headless build container.
TERM=xterm %make_build CFLAGS="%{optflags} -Wno-cpp" check

%install
%make_install

# Capture the complete installed file list without claiming unrelated system files.
find %{buildroot} \( -type f -o -type l \) ! -name '*.la' ! -path '%{buildroot}%{_mandir}/man1/*' ! -path '%{buildroot}%{_infodir}/*' | sed 's#^%{buildroot}##' | sort > %{_builddir}/gnucobol-filelist

%files -f %{_builddir}/gnucobol-filelist
%{_mandir}/man1/*.1*
%{_infodir}/*.info*
%license COPYING
