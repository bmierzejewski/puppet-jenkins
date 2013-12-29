# Class: jenkins
#
# This module manages jenkins
#
# Jenkins WAR is downloaded from Jenkins web site,
# then installed using a Ubuntu-managed tomcat{6|7} instance.
# IMPORTANT: You still need to configure /etc/default/tomcat{6|7} separately!
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class jenkins (
	$tomcat_version,
	$dist_uri           = 'http://mirrors.jenkins-ci.org/war/latest/jenkins.war',
	$private_key_source = '',
	$public_key_source  = '',
	$user_dir = '/home/jenkins'
) {
  $home     = "${user_dir}/.jenkins"
  $user     = "tomcat${tomcat_version}"

  file { jenkins-user-dir:
  	path    => $user_dir,
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => 0700,
    require => Package['tomcat'],
  }
  file { $home:
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => File['jenkins-user-dir'],
  }
  file { "${user_dir}/.ant":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => File['jenkins-user-dir'],
  }
  file { "${user_dir}/.ant/lib":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => File["${user_dir}/.ant"],
  }
  file { "${user_dir}/.ssh":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    require => File['jenkins-user-dir'],
  }
  if $private_key_source != '' {
    file { "${user_dir}/.ssh/id_rsa":
      ensure  => file,
      source  => $private_key_source,
      owner   => $user,
      group   => $user,
      mode    => 0600,
      require => File["${user_dir}/.ssh"],
    }
  }
  if $public_key_source != '' {
    file { "${user_dir}/.ssh/id_rsa.pub":
      ensure  => file,
      source  => $public_key_source,
      owner   => $user,
      group   => $user,
      mode    => 0644,
      require => File["${user_dir}/.ssh"],
    }
  }

  exec { name-jenkins:
    command   => "curl -v -L -o '/var/lib/${user}/webapps/jenkins.war' '${dist_uri}'",
    user      => $user,
    group     => $user,
    path      => ['/bin', '/usr/bin'],
    creates   => "/var/lib/${user}/webapps/jenkins.war",
    logoutput => true,
    require   => [ Package['tomcat'], File[$home] ],
  }

}
