# == Class consul_template::config
#
class consul_template::config inherits ::consul_template {

  file { [$::consul_template::config_dir, "${::consul_template::config_dir}/config"]:
    ensure  => 'directory',
    purge   => $::consul_template::purge_config_dir,
    recurse => $::consul_template::purge_config_dir,
    owner   => $::consul_template::user,
    group   => $::consul_template::group,
    mode    => '0755',
  }

  file { "${::consul_template::config_dir}/config/config.json":
    owner   => $::consul_template::user,
    group   => $::consul_template::group,
    mode    => '0660',
    content => consul_sorted_json($::consul_template::final_config_options, true),
  }

  # If nothing is specified for manage_service_file, defaults will be used
  # depending on the install_method.
  # If a value is passed, it will be interpretted as a boolean.
  if $::consul_template::manage_service_file == undef {
    case $::consul_template::install_method {
      'archive': { $real_manage_service_file = true  }
      'repo':    { $real_manage_service_file = false }
      default:   { $real_manage_service_file = false }
    }
  } else {
    validate_bool($::consul_template::manage_service_file)
    $real_manage_service_file = $::consul_template::manage_service_file
  }

  if $real_manage_service_file {
    case $::consul_template::service_provider {
      'upstart' : {
        file { '/etc/init/consul-template.conf':
          owner   => 'root',
          group   => 'root',
          mode    => '0444',
          content => template('consul_template/consul-template.upstart.erb'),
        }
        file { '/etc/init.d/consul-template':
          ensure => link,
          target => '/lib/init/upstart-job',
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
        }
      }
      'systemd' : {
        file { '/lib/systemd/system/consul-template.service':
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template('consul_template/consul-template.systemd.erb'),
        }
      }
      'redhat' : {
        file { '/etc/init.d/consul-template':
          owner   => 'root',
          group   => 'root',
          mode    => '0555',
          content => template('consul_template/consul-template.redhat.erb')
        }
      }
      'debian' : {
        file { '/etc/init.d/consul-template':
          owner   => 'root',
          group   => 'root',
          mode    => '0555',
          content => template('consul_template/consul-template.debian.erb')
        }
      }
      default : {
        fail("consul_template::service_provider '${::consul_template::service_provider}' is not valid")
      }
    }
  }

}
