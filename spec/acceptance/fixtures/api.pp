$source_dir = '/opt/openstack-health'

class { '::openstack_health':
  source_dir => $source_dir,
}

class { '::openstack_health::api':
  db_uri       => 'mysql+pymysql://query:query@logstash.openstack.org/subunit2sql',
  source_dir   => '/opt/openstack-health',
  server_admin => 'webmaster@localhost',
  vhost_name   => 'localhost',
  vhost_port   => 5000,
}
