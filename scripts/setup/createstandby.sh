#!/bin/bash
# Script for setting up primary database node

source /tmp/settings.sh
source /tmp/dbutils.sh

# Function definitions - start

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

StartStandby() {
  sleep 10
  WaitForPrimaryReady
  TakeBackup
  SetReplicaConfigurations
  CreateSignalFile
  StartDBServer
  WaitForExit
}
