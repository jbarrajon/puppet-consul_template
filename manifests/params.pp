# == Class consul_template::params
#
class consul_template::params {

  $bin_dir            = '/usr/local/bin'
  $config_dir         = '/etc/consul-template'
  $purge_config_dir   = true
  $download_dir       = '/opt/consul-template'
  $download_url       = undef
  $download_url_base  = 'https://releases.hashicorp.com/consul-template/'
  $download_extension = 'zip'
  $service_name       = 'consul-template'
  $service_enable     = true
  $service_ensure     = 'running'
  $service_options    = ''
  $manage_service      = true
  $manage_service_file = undef
  $user               = 'root'
  $group              = 'root'
  $manage_user        = false
  $manage_group       = false
  $install_method     = 'archive'
  $package_name       = 'consul-template'
  $package_ensure     = 'latest'
  $version            = '0.19.0'
  $config_options     = {
    'consul' => {
      'address' => '127.0.0.1:8500',
      'token' => 'abcd1234',
      'retry' => {
        'enabled' => true,
      }
    },
    'log_level' => 'warn',
    'wait' => {
      'min' => '5s',
      'max' => '10s',
    }
  }

  case $::osfamily {
    'Debian': {
      case $::operatingsystem {
        'Debian': {
          $service_provider = $::operatingsystemmajrelease ? {
            /^(4|5|6|7)$/ => 'debian',
            default       => 'systemd',
          }
        }
        'Ubuntu': {
          $service_provider = $::operatingsystemmajrelease ? {
            /^(12|13|14)\.(04|10)$/ => 'upstart',
            default                 => 'systemd',
          }
        }
        default: {
          fail("Module ${module_name} is not supported on '${::operatingsystem} ${::operatingsystemmajrelease}'")
        }
      }
    }
    'RedHat': {
      if ($::operatingsystemmajrelease == '6' or $::operatingsystem == 'Amazon') {
        $service_provider = 'redhat'
      } else {
        $service_provider = 'systemd'
      }
    }
    default: {
      fail("Module ${module_name} is not supported on osfamily '${::osfamily}'")
    }
  }
  case $::architecture {
    'x86_64', 'amd64': { $arch = 'amd64' }
    'i386':            { $arch = '386'   }
    /^arm.*/:          { $arch = 'arm'   }
    default:           {
      fail("Unsupported kernel architecture: ${::architecture}")
    }
  }
  $os = downcase($::kernel)

}
