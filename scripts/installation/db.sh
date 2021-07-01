#!/bin/bash
# Script to install Postgres or EPAS database

# Global variables
OS_TYPE=$1
USERNAME=$2
PASSWORD=$3
EPAS_REPO_URL=https://yum.enterprisedb.com/edbrepos/edb-repo-latest.noarch.rpm

# Function definitions - start

# Installs EPAS database server on CentOS7/RHEL7 platform
installEPASC7 () {
  yum -y install $EPAS_REPO_URL
  sed -i "s@<username>:<password>@$USERNAME:$PASSWORD@" /etc/yum.repos.d/edb.repo
  yum -y install "edb-as$DATABASE_VERSION-server"
  yum -y install sudo
}

# Installs EPAS database server on CentOS8/RHEL8 platform
installEPASC8 () {
  dnf -y install $EPAS_REPO_URL
  sed -i "s@<username>:<password>@$USERNAME:$PASSWORD@" /etc/yum.repos.d/edb.repo
  dnf -qy module disable postgresql
  dnf -y install "edb-as$DATABASE_VERSION-server"
  dnf -y install sudo
}

# Installs Postgres database server on CentOS7/RHEL7 platform
installPGC7 () {
  yum -y install sudo
  yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
  yum -y install "postgresql$DATABASE_VERSION-server"
}

# Installs Postgres database server on CentOS8/RHEL8 platform
installPGC8 () {
  dnf -y install sudo
  dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
  dnf -qy module disable postgresql
  dnf install -y "postgresql$DATABASE_VERSION-server"
}

# Script - start

if [ "$OS_TYPE" = "centos7" ]; then
  if [ "$DATABASE_TYPE" = "epas" ]; then
    installEPASC7
  else
    installPGC7
  fi
else
  if [ "$DATABASE_TYPE" = "epas" ]; then
    installEPASC8
  else
    installPGC8
  fi
fi