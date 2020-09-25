name 'vlt'
maintainer 'Alexander Pyatkin'
maintainer_email 'aspyatkin@gmail.com'
license 'MIT'
description "Chef resource to read secrets from HashiCorp's Vault"
version '0.1.0'

scm_url = 'https://github.com/aspyatkin/vlt-cookbook'
source_url scm_url if respond_to?(:source_url)
issues_url "#{scm_url}/issues" if respond_to?(:issues_url)

gem 'vault', '~> 0.15'
