#
# This script grabs the production database from the remote and copies it to a local folder ~/Backup.
# Meant to be executed in the backup environment, not on the production server itself.

UUID=`uuidgen`
mkdir -p ~/Backup
rsync -avz -e "ssh -i ~/.ssh/shared.pem" deploy@ec2-52-42-95-193.us-west-2.compute.amazonaws.com:/var/db/production.sqlite3 ~/Backup/production.sqlite3_backup_$UUID
