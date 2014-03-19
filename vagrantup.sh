#!/bin/bash

    if [ ! -f /vagrant/keys ];
    then
        mkdir keys
        cd keys
        openssl genrsa -aes128 -passout pass:secret -out id_rsa 2048
        openssl rsa -in id_rsa -passin pass:secret -out id_rsa.pub -pubout
        openssl rsa -in id_rsa -passin pass:secret -out id_rsa
    fi
    vagrant up