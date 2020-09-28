name 'vlt'
maintainer 'Alexander Pyatkin'
maintainer_email 'aspyatkin@gmail.com'
license 'MIT'
description "Chef helper lib to read secrets from HashiCorp's Vault"
version '0.2.1'

scm_url = 'https://github.com/aspyatkin/vlt-cookbook'
source_url scm_url if respond_to?(:source_url)
issues_url "#{scm_url}/issues" if respond_to?(:issues_url)

chef_version '>= 14.0'
%w( aix amazon centos fedora freebsd debian oracle mac_os_x redhat suse opensuseleap ubuntu windows zlinux ).each do |os|
  supports os
end

gem 'vault', '~> 0.15'
