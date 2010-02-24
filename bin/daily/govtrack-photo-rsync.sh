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

if [ ! -e "$data/govtrack/log/govtrack-photo-rsync.log" ]
then
  touch $data/govtrack/log/govtrack-photo-rsync.log
fi
cd $data/govtrack

echo "\n\nrsyncing govtrack photos at `date`" >> log/govtrack-photo-rsync.log
rsync -avz --exclude '*px.jpeg' govtrack.us::govtrackdata/photos . >> log/govtrack-photo-rsync.log

cd photos

sizes=( 42 73 102 )
rad=( 3 5 7)
for dir in 0 1 2
do
  if [ ! -d "thumbs_${sizes[dir]}" ]
    then
    mkdir "thumbs_${sizes[dir]}"
  fi
done
 
for i in `find . -maxdepth 1 -name \*.jpeg -print | awk '{FS="/"}{print $2}'`
do
	for size in 0 1 2
	do    	  
convert $i -thumbnail ${sizes[size]} -depth 8 -quality 95 \
     \( +clone  -threshold -1 \
        -draw "fill black polygon 0,0 0,${rad[size]} ${rad[size]},0 fill white circle ${rad[size]},${rad[size]} ${rad[size]},0" \
        \( +clone -flip \) -compose Multiply -composite \
        \( +clone -flop \) -compose Multiply -composite \
     \) +matte -compose CopyOpacity -composite thumbs_${sizes[size]}/`basename $i jpeg`png

   	echo "thumbs_${sizes[size]}/`basename $i jpeg`png... done"
  	done 	
done
