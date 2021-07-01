#!/bin/bash
# Script to install Postgres or EPAS database

# Global variables
DATABASE_TYPE=$1
DATABASE_VERSION=$2
OS_TYPE=$3
USERNAME=$4
PASSWORD=$5

# Function definitions - start

# Installs database server on CentOS7/RHEL7 platform
installEPASC7 () {
  yum -y install https://yum.enterprisedb.com/edbrepos/edb-repo-latest.noarch.rpm
  sed -i "s@<username>:<password>@$USERNAME:$PASSWORD@" /etc/yum.repos.d/edb.repo
  yum -y install "edb-as$DATABASE_VERSION-server"
  yum -y install sudo
}

# Installs database server on CentOS8/RHEL8 platform
installEPASC8 () {
  dnf -y install https://yum.enterprisedb.com/edbrepos/edb-repo-latest.noarch.rpm
  sed -i "s@<username>:<password>@$USERNAME:$PASSWORD@" /etc/yum.repos.d/edb.repo
  dnf -qy module disable postgresql
  dnf -y install "edb-as$DATABASE_VERSION-server"
}

if [ "$OS_TYPE" == "centos7" ]; then
  installEPASC7
else
  installEPASC8
fi