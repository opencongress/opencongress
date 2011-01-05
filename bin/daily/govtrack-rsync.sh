#!/bin/sh 
if [ -d "$1" ]
  then
  data=$1
else
  echo 'data dir not found! fix DATA_PATH in your environment file'
  exit
fi

if [ ! -d "$data/govtrack/log" ]
then
  mkdir -p $data/govtrack/log
fi

if [ ! -e "$data/govtrack/log/govtrack-rsync.log" ]
then
  touch $data/govtrack/log/govtrack-rsync.log
fi

cd $data/govtrack

echo "\n\nrsyncing govtrack at `date`" >> log/govtrack-rsync.log
rsync -avz govtrack.us::govtrackdata/us/people.xml . >> log/govtrack-rsync.log
rsync -avz --exclude '*.pdf' --exclude '*.png' govtrack.us::govtrackdata/us/112 . >> log/govtrack-rsync.log
rsync -avz --exclude '*.pdf' govtrack.us::govtrackdata/us/bills.text/112 ./bills.text/ >> log/govtrack-rsync.log
rsync -avz govtrack.us::govtrackdata/us/bills.text.cmp/112 ./bills.text.cmp/ >> log/govtrack-rsync.log
