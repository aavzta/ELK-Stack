#!/bin/bash

STR=$2
echo $1 $STR $3

Dealer_file="$1_Dealer_schedule"
Str_time=$(echo $STR | cut -d '-' -f 1)
Str_AM_PM=$(echo $STR | cut -d '-' -f 2)

if [ "$3" = "Blackjack" ] 
then
	grep $Str_time $Dealer_file |grep $Str_AM_PM | awk -F" " '{print "Blackjack dealer on " $1, $2,"was", $3, $4}' 

elif [ "$3" = "Roulette" ] 
then
	grep $Str_time $Dealer_file |grep $Str_AM_PM | awk -F" " '{print "Roulette dealer on " $1, $2,"was", $5, $6}'

elif [ "$3" = "Texas" ] 
then
	grep $Str_time $Dealer_file |grep $Str_AM_PM | awk -F" " '{print "Texas Hold-Em dealer on " $1, $2,"was", $7, $8}'
else
	echo "Not found. Confirm your 3x arguments was entered as [ddmm] [hh:00:00-AM or PM] [Blackjack or Roulette or Texas]"
fi
