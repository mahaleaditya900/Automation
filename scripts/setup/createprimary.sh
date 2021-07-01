#!/bin/bash
# Script for setting up primary database node

# Global variables
DATABASE_USER=enterprisedb
PGDATA=/tmp/my_data
PGENGINE=/usr/edb/as${DB_VERSION}/bin
AUTH=trust
DBPORT=5433
DATABASE_NAME=edb

# Function definitions - start

InitializeDB () {
  sudo -H -u $DATABASE_USER bash -c "$PGENGINE/initdb --pgdata=\"$PGDATA\" --no-locale"
}

UpdatePgHbaConf(){
  # add generic configurations
  echo "host all         all    0.0.0.0/0  $AUTH" >> $PGDATA/pg_hba.conf
  echo "host all  all    ::0/0  $AUTH" >> $PGDATA/pg_hba.conf
  echo "host replication all    0.0.0.0/0  $AUTH" >> $PGDATA/pg_hba.conf
  echo "host replication all ::0/0  $AUTH" >> $PGDATA/pg_hba.conf
}

UpdatePostgresqlConf(){
  echo "port = $DBPORT" >> $PGDATA/postgresql.conf
  echo "listen_addresses = '*'" >> $PGDATA/postgresql.conf
  echo "max_wal_senders = 5" >> $PGDATA/postgresql.conf
  echo "wal_level = hot_standby" >> $PGDATA/postgresql.conf
  echo "hot_standby = on" >> $PGDATA/postgresql.conf
  echo "max_replication_slots=5" >> $PGDATA/postgresql.conf
  echo "wal_keep_size=8000" >> $PGDATA/postgresql.conf
}

StartDBServer () {
  sudo -H -u $DATABASE_USER bash -c "$PGENGINE/pg_ctl -o \"-p $DBPORT\" -D $PGDATA start -w"
}

TakeBackup() {
  sudo -H -u $DATABASE_USER bash -c "$PGENGINE/pg_basebackup -U $DATABASE_USER -h $PRIMARY_IP -p $DBPORT --pgdata=$PGDATA --checkpoint=fast --write-recovery-conf"
}

SetReplicaConfigurations () {
  echo "primary_conninfo='user=$DATABASE_USER host=$PRIMARY_IP port=$DBPORT sslmode=prefer sslcompression=1 krbsrvname=postgres'" >> $PGDATA/postgresql.auto.conf
  echo "recovery_target_timeline='latest'" >> $PGDATA/postgresql.auto.conf
}

CreateSignalFile() {
  touch $PGDATA/standby.signal
  chmod 755 $PGDATA/standby.signal
}

WaitForPrimaryReady(){
  ready=false
  for i in `seq 1 30`;
  do
    $PGENGINE/pg_isready --host=$PRIMARY_IP --username=$DATABASE_USER --dbname=$DATABASE_NAME --port=$DBPORT --timeout=8

    if [ $? -eq 0 ]; then
      ready=true
      break
    fi
  done
}


WaitForExit(){
  while true; do
     sleep 30
  done
}

if [ "$NODE" = "primarydb" ]; then
  InitializeDB
  UpdatePostgresqlConf
  UpdatePgHbaConf
fi

if [ "$NODE" = "standbydb" ]; then
  sleep 10
  WaitForPrimaryReady
  TakeBackup
  SetReplicaConfigurations
  CreateSignalFile
fi

StartDBServer
WaitForExit