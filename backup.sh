#!/usr/bin/env bash

##   Command ./backup.sh [database_name] [username] [password] [retain_days]
##   database_name: Database name
##   username: username database
##   password: password database
##   retain_days: optional, 30 days default

################################################################
##   MySQL Database Backup Script
################################################################
export PATH=/bin:/usr/bin:/usr/local/bin

################################################################
################## Setup values  ###############################
DB_BACKUP_PATH="/home/$USER/backup"
TODAY=$(date +"%m-%d-%Y")
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
DATABASE_NAME=$1
MYSQL_USER=$2
MYSQL_PASSWORD=$3
BACKUP_RETAIN_DAYS=${4:-5}   ## Number of days to keep local backup copy

#################################################################
#################### RUN BACKUP DATABASE #########################
# first off, make our backup dir is existed
if [[ ! -d "$DB_BACKUP_PATH" ]];
    then mkdir -p ${DB_BACKUP_PATH}
fi

# then make new dir for today
mkdir -p ${DB_BACKUP_PATH}/${TODAY}

# carry out our process
mysqldump -h ${MYSQL_HOST} \
		  -P ${MYSQL_PORT} \
		  -u ${MYSQL_USER} \
		  -p${MYSQL_PASSWORD} \
		  ${DATABASE_NAME} | gzip > ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}.sql.gz

if [[ $? -eq 0 ]]; then
  echo "Database backup successfully completed"
else
  echo "Error found during backup"
fi

# deleting old database
OLD_DATABASE=`date +"%m-%d-%Y" --date="${BACKUP_RETAIN_DAYS} days ago"`

if [[ ! -z ${DB_BACKUP_PATH} ]]; then
      cd ${DB_BACKUP_PATH}
      if [[ ! -z ${OLD_DATABASE} ]] && [[ -d ${OLD_DATABASE} ]]; then
            rm -rf ${OLD_DATABASE}
            echo "Deleted database on ${OLD_DATABASE}";
      fi
fi

### End of script ####