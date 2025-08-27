# Cookbook:: clamav
#
# Provider:: config
#

# include  ClamAV::Helper

action :add do
  begin
    user = new_resource.user

    %w(clamav clamav-freshclam clamd).each do |pkg|
      dnf_package pkg do
        action :upgrade
      end
    end

    directory '/var/lib/clamav' do
      owner 'clamupdate'
      group 'clamupdate'
      mode '0775'
      recursive true
      action :create
    end

    directory '/var/log/clamav' do
      owner 'clamscan'
      group 'clamscan'
      mode '0775'
      recursive true
      action :create
    end

    template '/etc/clamd.d/scan.conf' do
      cookbook 'rb-clamav'
      source 'clamd.conf.erb'
      owner user
      group user
      mode '0644'
      retries 2
      notifies :restart, 'service[clamd@scan]', :delayed
    end

    template '/etc/freshclam.conf' do
      cookbook 'rb-clamav'
      source 'clamscan_freshclam.conf.erb'
      owner user
      group user
      mode '0644'
      retries 2
      notifies :restart, 'service[clamav-freshclam]', :delayed
    end

    execute 'initial_freshclam' do
      command '/usr/bin/freshclam --config-file /etc/freshclam.conf --stdout'
      only_if do
        sigs = Dir['/var/lib/clamav/*.{cvd,cld}']
        sigs.empty? || sigs.any? { |f| (Time.now - ::File.mtime(f)) > 24 * 3600 }
      end
      notifies :restart, 'service[clamd@scan]', :delayed
    end

    service 'clamav-freshclam' do
      service_name 'clamav-freshclam'
      ignore_failure true
      supports status: true, reload: true, restart: true, enable: true
      action [:enable, :start]
    end

    service 'clamd@scan' do
      service_name 'clamd@scan'
      ignore_failure true
      supports status: true, reload: true, restart: true, enable: true
      action [:enable, :start]
    end

    Chef::Log.info('ClamAV cookbook has been processed.')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin

    service 'clamav-freshclam' do
      service_name 'clamav-freshclam'
      ignore_failure true
      supports status: true, enable: true
      action [:stop, :disable]
    end

    service 'clamd@scan' do
      service_name 'clamd@scan'
      ignore_failure true
      supports status: true, enable: true
      action [:stop, :disable]
    end

    %w(clamav clamav-freshclam clamd).each do |pkg|
      dnf_package pkg do
        action :remove
      end
    end

    Chef::Log.info('ClamAV cookbook has been processed.')
  rescue => e
    Chef::Log.error(e.message)
  end
end
