# == Class: consul_template
#
# Installs, configures, and manages consul-template
#
# === Parameters
#
# [*bin_dir*]
#   Path where the consul-template binary will be linked to.
#
# [*config_dir*]
#   Path where consul-template configuration files are placed.
#
# [*purge_config_dir*]
#   Whether to purge config files not managed by Puppet.
#
# [*download_dir*]
#   Path to directory where downloaded files are stored.
#   Only valid when the install_method == archive.
#
# [*service_options*]
#   Extra arguments to be passed to the consul-template agent.
#
# [*user*]
#   The user to use for directory and file ownership. Defaults to root.
#
# [*group*]
#   The group to use for directory and file group. Defaults to root.
#
# [*manage_user*]
#   Whether to manage the user in this module. Defaults to `false`.
#
# [*manage_group*]
#   Whether to manage the group in this module. Defaults to `false`.
#
# [*install_method*]
#   Defaults to `archive` but can be `repo` if you want to install via a system package.
#
# [*package_name*]
#   Only valid when the install_method == repo. Defaults to `consul-template`.
#
# [*package_ensure*]
#   Only valid when the install_method == repo. Defaults to `latest`.
#
# [*version*]
#   Specify version of consul-template binary to download.
#
# [*config_options*]
#   A hash containing configuration file options for consul-template.
#
class consul_template (
  $bin_dir             = $::consul_template::params::bin_dir,
  $config_dir          = $::consul_template::params::config_dir,
  $purge_config_dir    = $::consul_template::params::purge_config_dir,
  $download_dir        = $::consul_template::params::download_dir,
  $download_url        = $::consul_template::params::download_url,
  $download_url_base   = $::consul_template::params::download_url_base,
  $download_extension  = $::consul_template::params::download_extension,
  $service_name        = $::consul_template::params::service_name,
  $service_provider    = $::consul_template::params::service_provider,
  $service_enable      = $::consul_template::params::service_enable,
  $service_ensure      = $::consul_template::params::service_ensure,
  $service_options     = $::consul_template::params::service_options,
  $manage_service      = $::consul_template::params::manage_service,
  $manage_service_file = $::consul_template::params::manage_service_file,
  $user                = $::consul_template::params::user,
  $group               = $::consul_template::params::group,
  $manage_user         = $::consul_template::params::manage_user,
  $manage_group        = $::consul_template::params::manage_group,
  $install_method      = $::consul_template::params::install_method,
  $package_name        = $::consul_template::params::package_name,
  $package_ensure      = $::consul_template::params::package_ensure,
  $version             = $::consul_template::params::version,
  $os                  = $::consul_template::params::os,
  $arch                = $::consul_template::params::arch,
  $config_options      = $::consul_template::params::config_options,
) inherits ::consul_template::params {

  validate_bool($purge_config_dir)
  validate_string($user)
  validate_string($group)
  validate_bool($manage_user)
  validate_bool($manage_group)
  validate_hash($config_options)

  $real_download_url = pick($download_url, "${download_url_base}${version}/${package_name}_${version}_${os}_${arch}.${download_extension}")

  $final_config_options = hiera_hash('consul_template::config_options', $config_options)

  include ::consul_template::install
  include ::consul_template::config
  include ::consul_template::service

  Class['::consul_template::install'] -> Class['::consul_template::config']
  Class['::consul_template::config'] ~> Class['::consul_template::service']

}
