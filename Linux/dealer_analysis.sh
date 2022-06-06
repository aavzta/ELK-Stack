#!/bin/bash

Dealer_file="$1_Dealer_schedule"
grep $2 $Dealer_file > tmp | grep $3 tmp > tmp2
awk -F" " '{print $1, $2, $5, $6}' tmp2 >> Dealers_working_during_losses







