#!/bin/bash

set -e
set -x

source "`dirname $0`/_functions.sh"

if [[ $# -lt 1 ]]
then
  usage
fi

FILENAME=$1
USERNAME=$2
HOSTNAME=$3

DIRNAME="2009-2003"
BASEURL="https://data.cityofnewyork.us/api/file_data/"
URL="${BASEURL}oz0tlTxRF1To-JafO4BcJIAj1wO45GTmM-3yt7gX2gk?filename=2009-2003.zip"
DBNAME="gentrify"

if [[ $HOSTNAME = x"" ]]
then
  HOSTNAME="localhost"
fi

CSVFILE="$FILENAME.csv"
ZIPFILE="$FILENAME.zip"
TABLENAME="$FILENAME"

download $URL $ZIPFILE
create_csv $DIRNAME $ZIPFILE
create_db $USERNAME $HOSTNAME $DBNAME
create_table $USERNAME $HOSTNAME $DBNAME $TABLENAME
load_data $USERNAME $HOSTNAME $DBNAME $TABLENAME $CSVFILE
