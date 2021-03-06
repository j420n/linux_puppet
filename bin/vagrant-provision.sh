#!/bin/bash
set -e

puppet_base='/vagrant/puppet'
to_provision='/vagrant/puppet/manifests/site.pp'

if [ -f /vagrant/vagrant.pp ] ;
then
  echo 'Found local vagrant.pp - using that instead'
  to_provision='/vagrant/vagrant.pp'
fi

#Don't change config if there are already keys
if [ ! -f /home/co/.ssh/id_rsa ];
then 
    echo "Host dev.dguteam.co.uk" >> /home/co/.ssh/config
    echo "    User vagrant_ro" >> /home/co/.ssh/config
    cp /vagrant/keys/id_rsa  /home/co/.ssh/id_rsa
    cp /vagrant/keys/id_rsa.pub  /home/co/.ssh/id_rsa.pub
    chown co: /home/co/.ssh/id_rsa.pub
    chown co: /home/co/.ssh/id_rsa
    chmod 600 /home/co/.ssh/id_rsa.pub /home/co/.ssh/id_rsa
    chmod 700 /home/co/.ssh
    echo dev > /etc/role


    #Temporary - need to add these to the base box?
    apt-get update
    rm -rf /etc/puppet
    ln -sf /vagrant/puppet /etc/
    ln -sf /etc/puppet/hiera.yaml /etc/
    #Symlink jar for solr
    ln -sf /etc/alternatives/jar /usr/local/bin/jar
    sudo gem uninstall librarian-puppet-maestrodev

    #remove hiera from /usr/local/bin
    sudo rm -rf /usr/bin/hiera

    #Use ruby 1.9.3 (which is called 1.9.1 on the basebox) else activesupport for librarian-puppet 0.9.11 is unavailable.
    sudo rm -rf /etc/alternatives/ruby
    sudo rm -rf /etc/alternatives/gem
    sudo ln -s /usr/bin/ruby1.9.1 /etc/alternatives/ruby
    sudo ln -s /usr/bin/gem1.9.1 /etc/alternatives/gem

    sudo gem install librarian-puppet
    #Hiera is already installed on the basebox and if it is not installed beluga will do it.
    #sudo gem install hiera
    sudo gem install hiera-eyaml
    #Update puppet module dependencies using librarian-puppet
    cd /vagrant/puppet
    librarian-puppet update

    if [ ! -f /vagrant/keys/private_key.pkcs7.pem ];
    then
        cd /vagrant
        eyaml  createkeys
    fi
fi



ln -sf /vagrant/hieradata /etc/
sudo /usr/bin/puppet apply --verbose \
  --manifestdir=${puppet_base}/manifests \
  --modulepath=${puppet_base}/modules \
  --hiera_config=${puppet_base}/hiera.yaml \
  ${to_provision}


#su co -c 'ssh -o StrictHostKeyChecking=no dev.data.gov.uk "echo Connection success" < /dev/null'
