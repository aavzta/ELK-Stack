#!/bin/bash

STR=$2
echo $1 $STR

Dealer_file="$1_Dealer_schedule"
Str_time=$(echo $STR | cut -d '-' -f 1)
Str_AM_PM=$(echo $STR | cut -d '-' -f 2)

grep $Str_time $Dealer_file |grep $Str_AM_PM | awk -F" " '{print "The Roulette dealer during " $1, $2,"was", $5, $6}' 
