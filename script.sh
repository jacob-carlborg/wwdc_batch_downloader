#!/bin/bash

#Setup the environment
mkdir tmp_download
cd tmp_download

year=2025
short_year=${year:2:2}
#Extract IDs
echo "Downloading the index"
wget -q "https://developer.apple.com/videos/wwdc$year/" -O index.html
#	find parts of the document where data-released=true, all the way to the first H4 header where title of that talk is
#	then find lines containing "videos/play/wwdc2018", then remove all chars except session number, then clean duplicated lines
cat index.html | htmlq -a href '[data-released="true"]' > ../downloadData

rm index.html

# cat index.html | htmlq -a href '[data-released="true"]'

#Iterate through the talk IDs
while read -r line
do
	#Download the page with the real download URL and the talk name
  wget -q "https://developer.apple.com$line" -O webpage

  # touch webpage
  # echo "https://developer.apple.com$line"

	#We grab the title of the page then clean it up
	talkName=$(cat webpage | htmlq -t title | sed -e "s/ \- WWDC$short_year.*//")

	#We grep "_hd_" which bring up the download URL, then some cleanup
	#If we were to want SD video, all we would have to do is replace _hd_ by _sd_
	dlURL=$(cat webpage | htmlq '[href*="_hd"]' -a href)

	rm webpage

	#Is there a video URL?
	if [ -z "$dlURL" ]; then
		echo
	else
		echo "Video $line ($talkName)"
		echo "	url: $dlURL"
		# Check if the file already exists
		if [ -f "../$talkName.mp4" ]; then
			echo "File '../$talkName.mp4' already exists. Skipping download."
		else
			# Great, we download the file
			wget -c "$dlURL" -O "../$talkName.mp4"
		fi
	fi
done < "../downloadData"

#cleanup
cd ..
rm -rf tmp_download
rm downloadData
