#!/bin/bash
##########################################
##### install req node-sonos-http-api ####
##########################################
directory=$(cd "$(dirname "$0")"; pwd)
source "$directory/sonos_adhan.cfg" 
#check if jq is installed
if hash jq 2>/dev/null; 
	then
#send push notivication with pushover
function AdhanPush() {
	if [[ $pushover_notifications = true ]]
		then
			#get data from config file
			wget https://api.pushover.net/1/messages.json --post-data="token=$app_token&user=$user_token&message=$2&title=$1" -qO- > /dev/null 2>&1 &
	fi
}
#get prayer times based on location from config file via API aladhan.com
function AdhanTimes() {

	url=$(curl -s "http://api.aladhan.com/timingsByCity?city=$city&country=$country&method=$method")
	#make a list of 5 prayes	
	declare -a arr=("Fajr" "Dhuhr" "Asr" "Maghrib" "Isha")
		#create a loop so each prayer gets a crontab
		for i in "${arr[@]}"
		do	
			#get the times from api
			pray=$(jq -r  '.data.timings.'$i <<< "${url}" ) 
			command="/bin/bash $directory/sonos_adhan.sh -adhan; crontab -l | grep -v DELETEME-${i,} | crontab"
			job="${pray:3:4} ${pray:0:2} * * * $command"
			cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab
			#create array message for push
			message+=($i" "$pray)
		done
		#send notification
		if [[ $salah_notification_install = true ]]
			then 
				AdhanPush "Prayers installed" "${message[@]}"
		fi 
}

function AdhanPlay(){
	#check is adhan is active
	if [[ $active = true ]]
		then 
		#if random is active create random number inshallah
		if [[ $random = true ]]
			then		
			random_number=$(printf "%02d" $((01 + RANDOM % 45))) #need to exclude
		else random_number=$(printf "%02d" "$adhan_number")
		fi
		#send notification
		if [[ $salah_notification_salah = true ]]
			then 
				AdhanPush "Salah" "It's time to pray"
		fi
		
		#check current hour for volume
		if [[ "$(date +%H)" > $adhan_time_day ]]
		then
			if [[ $adhan_preannounce = true ]]
				then 
					#replace space by url friendly space
					adhan_preannounce_text_format=${adhan_preannounce_text// /%20}
					curl --silent --output /dev/null http://localhost:5005/sayall/"$adhan_preannounce_text_format"/"$language"/"$adhan_volume_day"
					curl --silent --output --connect-timeout 560 /dev/null http://localhost:5005/clipall/"$random_number"-Adhan.mp3/"$adhan_volume_day"
			else
					curl --silent --output --connect-timeout 560 /dev/null http://localhost:5005/clipall/"$random_number"-Adhan.mp3/"$adhan_volume_day"
			fi

		#if it's night
		else
			if [[ $adhan_preannounce = true ]]
				then 
					#replace space by url friendly space
					adhan_preannounce_text_format=${adhan_preannounce_text// /%20}
					curl --silent --output /dev/null http://localhost:5005/sayall/"$adhan_preannounce_text_format"/"$language"/"$adhan_volume_night"
					curl --silent --output --connect-timeout 560 /dev/null http://localhost:5005/clipall/"$random_number"-Adhan.mp3/"$adhan_volume_night"
			else
					curl --silent --output --connect-timeout 560 /dev/null http://localhost:5005/clipall/"$random_number"-Adhan.mp3/"$adhan_volume_night"
			fi
		fi
	fi
}
#install adhan time from api
if [[ $1 == -install ]];then 
		AdhanTimes
#play the adhan
elif [[ $1 == -adhan ]];then	
		AdhanPlay
fi
# end if for jq check
    else
        sudo apt install jq -y
fi
