# == Class consul_template::install
#
class consul_template::install inherits ::consul_template {

  case $::consul_template::install_method {
    'archive': {
      file { $::consul_template::download_dir:
        ensure => 'directory',
        owner  => $::consul_template::user,
        group  => $::consul_template::group,
        mode   => '0755',
      }
      file { "${::consul_template::download_dir}/${::consul_template::version}":
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
      } ->
      archive { "${::consul_template::download_dir}/${::consul_template::version}.${::consul_template::download_extension}":
        ensure       => present,
        source       => $::consul_template::real_download_url,
        extract      => true,
        extract_path => "${::consul_template::download_dir}/${::consul_template::version}",
        creates      => "${::consul_template::download_dir}/${::consul_template::version}/consul-template",
      } ->
      file { "${::consul_template::download_dir}/${::consul_template::version}/consul-template":
        owner => 'root',
        group => 'root',
        mode  => '0555',
      }
      file { "${::consul_template::bin_dir}/consul-template":
        ensure => link,
        target => "${::consul_template::download_dir}/${::consul_template::version}/consul-template",
      }
    }
    'repo': {
      package { 'consul-template':
        ensure => $::consul_template::package_ensure,
        name   => $::consul_template::package_name,
      }
    }
    default: {
      fail("Installation method ${::consul_template::install_method} not supported")
    }
  }

  if $::consul_template::manage_user {
    user { $::consul_template::user:
      ensure => 'present',
      system => true,
    }
    if $::consul_template::manage_group {
      Group[$::consul_template::group] -> User[$::consul_template::user]
    }
  }
  if $::consul_template::manage_group {
    group { $::consul_template::group:
      ensure => 'present',
      system => true,
    }
  }

}
