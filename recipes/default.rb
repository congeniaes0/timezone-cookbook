#
# Cookbook Name:: timezone-cookbook
# Recipe:: default
#
# Copyright (c) 2015 Congenia Integracion

ruby_block "add locale information" do
  block do
    fe = Chef::Util::FileEdit.new("/etc/environment")
    fe.insert_line_if_no_match(/LANG=en_US/,
                               "LANG=en_US\nLC_ALL=\"en_US.utf8\"")
    fe.write_file
  end
  notifies :run, 'bash[source]'
end

bash "source" do
  code "source /etc/environment"
  action :nothing
end

package "tzdata"

template "/etc/timezone" do
  source "timezone.conf.erb"
  owner 'root'
  group 'root'
  mode 0644
  notifies :run, 'bash[dpkg-reconfigure tzdata]'
end

bash 'dpkg-reconfigure tzdata' do
  user 'root'
  code "/usr/sbin/dpkg-reconfigure -f noninteractive tzdata"
  action :nothing
  notifies :run, 'bash[restart_rsyslog]'
end

bash 'restart_rsyslog' do
  action :nothing
  code "service rsyslog restart"
end
