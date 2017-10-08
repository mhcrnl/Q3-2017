#
# Project: grandfatherclock
# File:    installation script
# Type:    RedHat package manager configuration
#
%define name grandfatherclock
%define version 1.0.1
%define release 1suse

Distribution: SuSE Linux 6.3
Name:         grandfatherclock
Release:      %{release}
Version:      %{version}

Copyright:    GPL 2000 Dr. Robert J. Meier
Packager:     Dr. Robert J. Meier <robert.meier@computer.org>
Group:        Games
Provides:     %{name}
Requires:     perl >= 5.0.0

Source:       %{name}-%{version}.tar.gz
Prefix:       /etc/%{name}
Prefix:       %{_bindir}
Prefix:       %{_mandir}

Summary:      grandfatherclock tolls the time acoustically


%description
grandfatherclock plays audio files to report the time.  The
default  configuration  emulates  a grandfather  clock with
Westminister chimes.   Cuckoo clock and Close Encounters of
the Third Kind files are included.


%prep
%setup -q


%build


%install
cp -pr . /opt/%{name}
if test -L %{_bindir}/%{name}; then rm %{_bindir}/%{name}; fi
ln -s /opt/%{name}/bin/grandfatherclock %{_bindir}/%{name}
mkdir -p /etc/%{name}
cp etc/grandfatherclockrc /etc/%{name}/%{name}rc
gzip -c doc/grandfatherclock.6 > %{_mandir}/man6/%{name}.6.gz


%clean


%files
%{_bindir}/%{name}
/opt/%{name}
%config /etc/%{name}
%{_mandir}/man6/%{name}.6.gz

%changelog
* Mon Jul 21 2000 Dr. Robert J. Meier <robert.meier@computer.org> 1.0.0-1suse
- Packaged for SuSE 6.3
