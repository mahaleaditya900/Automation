#!/bin/bash

PGDATA=/tmp/my_data
DBPORT=5433
AUTH=trust

if [ "$DATABASE_TYPE" = "epas" ]; then
  DATABASE_USER=enterprisedb
  PGENGINE=/usr/edb/as${DATABASE_VERSION}/bin
  DATABASE_NAME=edb
else
  DATABASE_USER=postgres
  PGENGINE=/usr/pgsql-${DATABASE_VERSION}/bin
  DATABASE_NAME=postgres
fi
