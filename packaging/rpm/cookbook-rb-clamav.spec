Name:     cookbook-rb-clamav
Version:  %{__version}
Release:  %{__release}%{?dist}
BuildArch: noarch
Summary: clamav cookbook to install and configure it in redborder environments


License:  GNU AGPLv3
URL:  https://github.com/redBorder/cookbook-rb-clamav
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/rb-clamav
mkdir -p %{buildroot}/usr/lib64/rb-clamav

cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/rb-clamav/
chmod -R 0755 %{buildroot}/var/chef/cookbooks/rb-clamav
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/rb-clamav/README.md

%pre
if [ -d /var/chef/cookbooks/rb-clamav ]; then
    rm -rf /var/chef/cookbooks/rb-clamav
fi

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload rb-clamav'
  ;;
esac

%postun
# Deletes directory when uninstall the package
if [ "$1" = 0 ] && [ -d /var/chef/cookbooks/rb-clamav ]; then
  rm -rf /var/chef/cookbooks/rb-clamav
fi

systemctl daemon-reload
%files
%attr(0755,root,root)
/var/chef/cookbooks/rb-clamav
%defattr(0644,root,root)
/var/chef/cookbooks/rb-clamav/README.md

%doc

%changelog
* Thu Oct 10 2024 Miguel Negrón <manegron@redborder.com>
- Add pre and postun

* Mon Jun 18 2024 - Miguel Álvarez <malvarez@redborder.com>
- Initial spec version
