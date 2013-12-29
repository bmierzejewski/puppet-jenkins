define jenkins::plugin(
  $version = 'latest',
	$tomcat_version = 6,
	$plugin_parent_dir = '/home/jenkins'
) {
  $plugin            = "${name}.hpi"
  $plugin_dir        = "${plugin_parent_dir}/plugins"
  $user              = "tomcat${tomcat_version}"
	$plugin_full_path  = "${plugin_dir}/${$plugin}"

  if ($version != 'latest') {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}/"
  }
  else {
    $base_url = 'http://updates.jenkins-ci.org/latest/'
  }

  if (!defined(File[$plugin_dir])) {
    file {
      [$plugin_dir]:
        ensure  => directory,
        owner   => $user,
        group   => $user,
        require => [Group[$user], User[$user]]
    }
  }

  if (!defined(Group[$user])) {
    group {
      $user :
        ensure => present;
    }
  }

  if (!defined(User[$user])) {
    user {
      $user :
        ensure => present;
    }
  }

  exec {
    "download-${name}" :
      command    => "wget --no-check-certificate ${base_url}${plugin}",
      cwd        => $plugin_dir,
      require    => File[$plugin_dir],
      path       => ['/usr/bin', '/usr/sbin',],
      unless     => "test -f ${plugin_dir}/${name}.hpi || test -f ${plugin_dir}/${name}.jpi",
  }

  file {
    "${plugin_dir}/${plugin}" :
      require => Exec["download-${name}"],
      owner   => $user,
			group   => $user,
      mode    => '0644',
			notify  => Service['tomcat']
  }
}
