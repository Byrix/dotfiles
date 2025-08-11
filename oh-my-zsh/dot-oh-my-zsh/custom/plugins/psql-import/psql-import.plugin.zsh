# Load .env file 
# Expects:
#   - USER=database username
#   - PASSWORD=database password
#   - OGR_PATH=path to ogr2ogr
set -a 
source ${0:a:h}/.env 
set +a

function psqlimport() {
  # $1 dbname
  # $2 schema
  # $3 folder
  if [[ -z $1 ]]; then
    echo "Please specify a database name"
    return
  else
    local db=$1
  fi

  local file
  local schema
  if [[ -z $2 ]]; then
    echo "Usage: psqlimport [dbname] (schema) [import folder]"
    return
  fi
  if [[ -z $3 ]]; then
    file=$2
  else
    schema=$2
    file=$3
  fi

  local path=${0:a}/$file
  if [[ -d $path ]]; then
    echo "$path does not exist"
    return
  fi

  local conn="host=localhost dbname=$db user=$USER password=$PASSWORD"
  local ogr=$OGR_PATH/ogr2ogr
  for f in ./$file/**/*.shp; do
    echo "\n$f"
    if [[ -z $schema ]]; then
      $ogr -f "PostgreSQL" PG:"$conn" $f
      [[ $? -ne 0 ]] && echo "Error $?"
    else
      $ogr -f "PostgreSQL" PG:"$conn" -lco SCHEMA=$schema $f
      [[ $? -ne 0 ]] && echo "Error $?"
    fi
  done
}
