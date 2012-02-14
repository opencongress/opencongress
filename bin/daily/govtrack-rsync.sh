#!/bin/sh 
if [ -d "$1" ]
  then
  data=$1
else
  echo 'data dir not found! trying to create file...'
  mkdir -p $1

  if [ ! -d "$1" ]
  then
    echo 'could not create $1!'
    exit
  fi

  data=$1
fi

if [ ! -d "$data/govtrack" ]
then
  mkdir -p $data/govtrack
fi

if [ ! -d "$data/govtrack/bills.text" ]
then
  mkdir -p $data/govtrack/bills.text
fi

if [ ! -d "$data/govtrack/bills.text.cmp" ]
then
  mkdir -p $data/govtrack/bills.text.cmp
fi

cd $data

echo "\n\nrsyncing govtrack at `date`"
rsync -avz govtrack.us::govtrackdata/us/people.xml ./govtrack/
rsync -avz --exclude '*.pdf' --exclude '*.png' govtrack.us::govtrackdata/us/112 ./govtrack/
rsync -avz --exclude '*.pdf' govtrack.us::govtrackdata/us/bills.text/112 ./govtrack/bills.text/ 
rsync -avz govtrack.us::govtrackdata/us/bills.text.cmp/112 ./govtrack/bills.text.cmp/
