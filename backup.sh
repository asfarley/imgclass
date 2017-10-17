#
# Create backup copy of production database.
#
DATE=`date +%Y-%m-%d`
cp /var/db/production.sqlite3 /var/db/production.sqlite3.backup_$DATE
