#!/bin/sh 
if [ -d "$1" ]
  then
  data=$1
else
  echo 'data dir not found! fix DATA_PATH in your environment file'
  exit
fi
cd $1/govtrack
if [ ! -d "log" ]
then
  mkdir log
fi
if [ ! -e "log/govtrack-rsync.log" ]
then
  touch log/govtrack-rsync.log
fi

echo "\n\nrsyncing govtrack at `date`" >> log/govtrack-rsync.log
rsync -avz --progress govtrack.us::govtrackdata/us/people.xml . >> log/govtrack-rsync.log
rsync -avz --progress govtrack.us::govtrackdata/us/111 . >> log/govtrack-rsync.log
rsync -avz --progress govtrack.us::govtrackdata/us/bills.text/111 ./bills.text/ >> log/govtrack-rsync.log
rsync -avz --progress govtrack.us::govtrackdata/us/bills.text.cmp/111 ./bills.text.cmp/ >> log/govtrack-rsync.log