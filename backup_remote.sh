#
# This script grabs the production database from the remote and copies it to a local folder ~/Backup.
# Meant to be executed in the backup environment, not on the production server itself.

UUID=`uuidgen`
USER=deploy
URL=${SERVER_URL}
BACKUP_PATH=/tmp/backup
mkdir -p $BACKUP_PATH
rsync -avz -e "ssh -i ~/.ssh/shared.pem" $USER@$URL:/var/db/production.sqlite3 $BACKUP_PATH/production.sqlite3_backup_$UUID
