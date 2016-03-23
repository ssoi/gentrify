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
  
  PRINTHEADER=1
  for XLS in $XLSFILES
  do
    in2csv $XLS | awk -v print_header=$PRINTHEADER 'BEGIN {
       is_header = 0
     }
     {
       if (is_header == 1) {
         gsub(/\ *,/, ",", $0);
         print($0);
       } else {
         if ($0 !~ /[a-z]/ && $0 !~ /[0-9]/) {
           if (print_header == 1)
             print($0);
           is_header = 1;
         }
       }
     }' >> $FILE
    PRINTHEADER=0
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

  SCRIPT=`mktemp 2> /dev/null || mktemp -t tmp`
cat << SQL > $SCRIPT
CREATE TABLE IF NOT EXISTS $TABLE (
  borough TEXT,
  neighborhood TEXT,
  building_class_category TEXT,
  tax_class_present TEXT,
  block TEXT,
  lot TEXT,
  easement TEXT,
  building_class_present TEXT,
  address TEXT,
  zip_code TEXT,
  residential_units REAL,
  commercial_units REAL,
  total_units REAL,
  land_square_feet REAL,
  gross_square_feet REAL,
  year_built TEXT,
  tax_class_sale TEXT,
  building_class_sale TEXT,
  sale_price REAL,
  sale_date TEXT);
SQL

  psql --user=$USER --host=$HOST --dbname=$DBNAME --file=$SCRIPT
  rm $SCRIPT
}

load_data() {
  USER=$1
  HOST=$2
  TABLE=$3
  DBNAME=$4
  FILE=$5
  SCRIPT=`mktemp --tmpdir="." 2> /dev/null || mktemp -t tmp`
cat << SQL > $SCRIPT
\copy $TABLE FROM '$FILE' DELIMITERS ',' CSV HEADER;
SQL

  psql --user=$USER --host=$HOST --dbname=$DBNAME --file=$SCRIPT
  rm $SCRIPT
}
