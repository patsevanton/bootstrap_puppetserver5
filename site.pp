$master_host = 'puppet.my.domain'
$puppetdb_host = 'puppetdb.my.domain'

node 'puppet.my.domain' {
  # Here we configure the Puppet master to use PuppetDB,
  # telling it the hostname of the PuppetDB node
  class { 'puppetdb::master::config':
    puppetdb_server => $puppetdb_host,
  }
}
node 'puppetdb.my.domain' {
  # Here we install and configure PostgreSQL and the PuppetDB
  # database instance, and tell PostgreSQL that it should
  # listen for connections to the `$postgres_host`
  class { 'puppetdb::database::postgresql':
    listen_addresses => $puppetdb_host,
  }
  class { 'puppetdb::server':
    database_host => $puppetdb_host,
  }
  # Firewall implementation firewall puppet needed
  firewall { '001 Open port 8081 for sending data to puppetdb and 8080 for dashboard view':
    dport   => [8081,8080],
    proto  => tcp,
    action => accept,
  }
}
