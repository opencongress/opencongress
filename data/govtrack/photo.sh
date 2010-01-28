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
if [ ! -e "log/govtrack-photo-rsync.log" ]
then
  touch log/govtrack-photo-rsync.log
fi

echo "\n\nrsyncing govtrack photos at `date`" >> log/govtrack-photo-rsync.log
rsync -avz --progress --exclude '*px.jpeg' govtrack.us::govtrackdata/photos . >> log/govtrack-photo-rsync.log
cd photos

sizes=( 42 73 102 )
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
convert $i \
     \( +clone  -threshold -1 \
        -draw 'fill black polygon 0,0 0,8 8,0 fill white circle 8,8 8,0' \
        \( +clone -flip \) -compose Multiply -composite \
        \( +clone -flop \) -compose Multiply -composite \
     \) +matte -compose CopyOpacity -composite -thumbnail ${sizes[size]} -depth 8 -quality 95 thumbs_${sizes[size]}/`basename $i jpeg`png

   	echo "thumbs_${sizes[size]}/`basename $i jpeg`png... done"
  	done 	
done
