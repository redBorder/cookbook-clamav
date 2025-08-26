# Cookbook:: clamav
#
# Provider:: config
#

# include  ClamAV::Helper

action :add do
  begin
    user = new_resource.user

    %w[clamav clamav-freshclam clamd].each do |pkg|
      dnf_package pkg do
        action :upgrade
      end
    end

    service 'clamav-freshclam' do
      service_name 'clamav-freshclam'
      ignore_failure true
      supports status: true, reload: true, restart: true, enable: true
      action :nothing
    end

    service 'clamd@scan' do
      service_name 'clamd@scan'
      ignore_failure true
      supports status: true, reload: true, restart: true, enable: true
      action :nothing
    end

    template "/etc/clamd.d/scan.conf" do
      source "clamd.conf.erb"
      owner user
      group user
      mode '0644'
      retries 2
      notifies :restart, 'service[clamd@scan]'
    end

    template "/etc/freshclam.conf" do
      source "clamscan_freshclam.conf.erb"
      owner user
      group user
      mode '0644'
      retries 2
      notifies :restart, 'service[clamav-freshclam]'
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

    unless File.exist?("/var/lib/clamav/daily.cld")
      execute "update_clamav_database" do
          ignore_failure true
          command "/usr/bin/freshclam --config-file /etc/freshclam.conf"
          action :run
      end
    end
  end

    service 'clamav-freshclam' do
      action [:enable, :start]
    end

    service 'clamd@scan' do
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

    %w[clamav clamav-freshclam clamd].each do |pkg|
      dnf_package pkg do
        action :remove
      end
    end

    Chef::Log.info('ClamAV cookbook has been processed.')
  rescue => e
    Chef::Log.error(e.message)
  end
end
