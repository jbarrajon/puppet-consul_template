# == Class consul_template::service
#
class consul_template::service inherits ::consul_template {

  if $::consul_template::manage_service {
    service { 'consul-template':
      ensure   => $::consul_template::service_ensure,
      enable   => $::consul_template::service_enable,
      name     => $::consul_template::service_name,
      provider => $::consul_template::service_provider,
    }
  }

}
