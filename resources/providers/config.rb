# Cookbook:: clamav
#
# Provider:: config
#
action :add do
  begin
    user = new_resource.user

    dnf_package 'clamav' do
      action :upgrade
      flush_cache[:before]
    end

    # TODO: do something with clamav

    Chef::Log.info('cookbook clamav has been processed.')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin

    # TODO : service stop

    Chef::Log.info('cookbook clamav has been processed.')
  rescue => e
    Chef::Log.error(e.message)
  end
end
