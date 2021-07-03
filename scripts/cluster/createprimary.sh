#!/bin/bash
# Script for setting up primary database node

source /tmp/settings.sh
source /tmp/dbutils.sh

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

StartPrimary() {
  InitializeDB
  UpdatePostgresqlConf
  UpdatePgHbaConf
  StartDBServer
  WaitForExit
}
