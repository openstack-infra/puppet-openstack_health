$source_dir = '/opt/openstack-health'

class { '::openstack_health':
  source_dir => $source_dir,
}

class { '::openstack_health::frontend':
  source_dir   => '/opt/openstack-health',
  serveradmin  => 'webmaster@localhost',
  vhost_name   => 'localhost',
  vhost_port   => 80,
  api_endpoint => 'http://localhost:5000',
}
