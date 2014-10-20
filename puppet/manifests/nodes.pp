node default {
  crit( "Node only matched \"default\" for which there is no configuration, $::hostname" )
}

node /.*\.dgudev/ {
  class { 'sudo':
    purge               => false,
    config_file_replace => false,
  }

  include dgu_defaults

  # Thinking of modifying this for your own needs?
  # Don't! Create 'vagrant.pp' in the same directory
  # as your Vagrantfile and the vagrant provisioner
  # will use that instead.

  class {"beluga::developer_tools":
    install_git => true,
    install_vim => true,
  }

  class { 'beluga::facts::role':
    stage => pre,
    role => 'dev',
  }

  class { "beluga::frontend_traffic_director":
    extra_selectors           => $extra_selectors,
    frontend_domain           => 'dgud7',
    backend_domain            => 'dgud7',
  }

  class {'beluga::apache_frontend_server':
    domain_name               => 'dgud7',
    owner                     => 'co',
    group                     => 'co'
  }

  class { 'solr':
    source_dir => "puppet:///modules/dgu_solr/solr",
    source_dir_purge => true,
  }

  class {'beluga::mysql_server': }

  class { 'beluga::drush_server': }

  class { 'beluga::mail_server': }

  class { 'jenkins':
    configure_firewall => false,
  }

  class { 'beluga::ruby_frontend':  }

 # The puppet elda module included in orgdc currently has an issue with librarian puppet.
 # include orgdc
}


node standards {

  include prod_defaults

  class {"beluga::developer_tools":
    install_git => true,
  }

  class {'beluga::apache_frontend_server': }

  class {'beluga::mysql_server': }

  class { 'beluga::drush_server': }
  include standards_site

}

node puppetmaster {
  include prod_defaults
}

node dataconversion {
  include epimorphics_defaults
  include java
  class { "tomcat":
  }
  include orgdc
}

node dataservice {
  include epimorphics_defaults
  include java
  class { "tomcat":
  }
}

node epdev {
  include epimorphics_defaults
  include java
  class { "tomcat":
  }
}
