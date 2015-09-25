# Install and maintain OpenStack Health.
# params:
#   source_dir:
#     The directory where the application will be running
#   serveradmin:
#     Used in the Apache virtual host, eg., openstack-health@openstack.org
#   vhost_name:
#     Used in the Apache virtual host, eg., health.openstack.org
#   vhost_port:
#     Used in the Apache virtual host, eg., 5000
#   api_endpoint:
#     The URL where openstack-health API is running
class openstack_health::frontend(
  $source_dir = '/opt/openstack-health',
  $serveradmin = "webmaster@${::fqdn}",
  $vhost_name = 'localhost',
  $vhost_port = 80,
  $api_endpoint = 'http://localhost:5000',
) {

  $frontend_dir = "${source_dir}/build"

  class { '::nodejs':
    legacy_debian_symlinks => true,
    repo_url_suffix        => 'node_0.12',
  }

  package { 'node-gyp':
    ensure   => present,
    provider => npm,
    require  => Class['::nodejs'],
  }

  package { 'gulp':
    ensure   => present,
    provider => npm,
    require  => Class['::nodejs'],
  }

  exec { 'install-frontend-requirements':
    command   => 'npm install',
    cwd       => $source_dir,
    path      => ['/usr/local/bin/', '/usr/bin/', '/bin/'],
    timeout   => 900,
    require   => [
      Package['gulp'],
      Package['node-gyp'],
    ],
    subscribe => Vcsrepo[$source_dir],
  }

  exec { 'build-static-files':
    command   => 'gulp prod',
    cwd       => $source_dir,
    path      => ['/usr/local/bin/', '/usr/bin/', '/bin/'],
    require   => Exec['install-frontend-requirements'],
    subscribe => Vcsrepo[$source_dir],
  }

  ::httpd::vhost { "${vhost_name}-frontend":
    docroot  => 'MEANINGLESS ARGUMENT',
    port     => $vhost_port,
    priority => '100',
    ssl      => false,
    template => 'openstack_health/openstack-health-frontend.vhost.erb',
    require  => Exec['build-static-files'],
  }
}
