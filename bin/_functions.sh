usage() {
  echo "$0: <csv> <username> [host]"
  exit 1  
}

download() {
  URL=$1
  FILE=$2

  curl --output $FILE $URL
  unzip $FILE
}

create_csv() {
  DIR=$1
  FILE=$2
  XLSFILES=`find $DIR -name '*.xls'`
  
  CNT=0  
  for XLS in $XLSFILES
  do
    if [[ $CNT = 0 ]]
    then
      SKIP="+5"
    else
      SKIP="+6"
    fi
    CNT=1
    in2csv $XLS | tail -n $SKIP >> $FILE
  done
}

create_db() {
  USER=$1
  HOST=$2
  DBNAME=$3
  
  createdb --user=$USER --host=$HOST $DBNAME
}

create_table() {
  USER=$1
  HOST=$2
  DBNAME=$3
  TABLE=$4

  SCRIPT=`mktemp -t tmp`
cat << SQL > $SCRIPT
CREATE TABLE IF NOT EXISTS $TABLE (
  borough INTEGER,
  neighborhood TEXT,
  building_class_category TEXT,
  tax_class_present TEXT,
  block TEXT,
  lot TEXT,
  easement TEXT,
  building_class_present TEXT,
  address TEXT,
  zip_code TEXT,
  residential_units INTEGER,
  commercial_units INTEGER,
  total units INTEGER,
  land_square_feet INTEGER,
  gross_square_feet INTEGER,
  year_built TEXT,
  tax_class_sale TEXT,
  building_class_sale TEXT,
  sale_price INTEGER,
  sale_date TEXT,
  key_id SERIAL PRIMARY KEY);
SQL

  psql --user=$USER --host=$HOST --dbname=$DBNAME --file=$SCRIPT
  rm $SCRIPT
}

load_data() {
  USER=$1
  HOST=$2
  TABLE=$3
  FILE=$4
  
  SCRIPT=`mktemp -t gentrify`
cat << SQL > $SCRIPT
COPY $TABLE FROM '$FILE' DELIMITERS ',' CSV HEADER;
SQL

  psql --user=$USER --host=$HOST --dbname=$DBNAME --file=$SCRIPT
  rm $SCRIPT
}
