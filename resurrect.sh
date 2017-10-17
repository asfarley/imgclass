FILE=/var/db/production.sqlite3

if [ -f $FILE ]; then
   echo "Production database ($FILE) exists, resurrection terminated. Delete production database manually if necessary."
else
   echo "Grabbing most recent database from backups..."
   MOST_RECENT_DB=`ls -t /var/db/production.sqlite3* | head -1`
   cp $MOST_RECENT_DB /var/db/production.sqlite3
   echo "Done."
fi
