class servicenow_integration::puppetserver (
  String $snowinstance,
  String $user,
  String $password,
  String $table,
  String $sys_id
) {
  $gem_build_dependencies = (
    package { ['make', 'automake', 'gcc', 'gcc-c++', 'kernel-devel']:
      ensure => present,
    }
  )

  $resource_dependencies = flatten([
    ['puppet_gem', 'puppetserver_gem'].map |$provider| {
      package { "${provider} cassandra-driver":
        ensure   => present,
        name     => 'cassandra-driver',
        provider => $provider,
        require  => $gem_build_dependencies,
      }
    },

    file { '/etc/puppetlabs/puppet/get-snow-node-data.rb':
      ensure => file,
      owner  => 'pe-puppet',
      group  => 'pe-puppet',
      mode   => '0755',
      source => 'puppet:///modules/servicenow_integration/get-snow-node-data.rb',
    },

    file { '/etc/puppetlabs/puppet/snow_record.yaml':
      ensure  => file,
      owner   => 'pe-puppet',
      group   => 'pe-puppet',
      mode    => '0640',
      content => epp('servicenow_integration/snow_record.yaml.epp', {
        snowinstance => $snowinstance,
        user         => $user,
        password     => $password,
        table        => $table,
        sys_id       => $sys_id
      }),
    },
  ])

  pe_ini_setting { 'puppetserver puppetconf trusted external script':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    setting => 'trusted_external_command',
    value   => '/etc/puppetlabs/puppet/get-snow-nodedata.rb',
    section => 'master',
    require => $resource_dependencies,
  }
}
