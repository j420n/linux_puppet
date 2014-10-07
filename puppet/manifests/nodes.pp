node default {
  crit( "Node only matched \"default\". Config from common.yaml and any facts will be used as well as any hieradata which matches this fqdn ->, $::hostname" )
}


#INCLUDE CLASSES DECLARED IN HIERADATA
hiera_include("classes")


#node 'vagrant.dgudev'
#Configuration for this node has moved to vagrant.yaml .


node standards {

  include prod_defaults

  class {"beluga::developer_tools":
    install_git => true,
  }

  class { 'beluga::facts::role':
    stage => pre,
    role => 'prod',
  }

  class { 'beluga::facts::site':
    stage => pre,
    site => 'standards',
  }

  class {'beluga::apache_frontend_server': }

  class {'beluga::mysql_server': }

  class { 'beluga::drush_server': }

}

node puppetmaster {
  include prod_defaults
}

node dataconversion {
  include epimorphics_defaults
  include java
  class { "tomcat":
    java_home => $java::java_home,
    http_port => 8080,
  }
  include orgdc
}

node dataservice {
  include epimorphics_defaults
  include java
  class { "tomcat":
    java_home => $java::java_home,
    http_port => 8080,
  }
}

node epdev {
  include epimorphics_defaults
  include java
  class { "tomcat":
    java_home => $java::java_home,
    http_port => 8080,
  }
}
