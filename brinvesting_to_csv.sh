#!/bin/bash

if [[ $# -lt 2 ]]; then
	echo "Usage: $0 stock_name Monthly|Weekly|Daily" 
	exit
fi

STOCK="$1"
STOCK_ID=$(grep $STOCK paths.txt | cut -d";" -f3)

PERIOD=$2

# echo $PERIOD
# exit

D=$(date +%d)
M=$(date +%m)
Y=$(date +%Y)

curl -s 'https://br.investing.com/instruments/HistoricalDataAjax' \
	'Origin: https://br.investing.com' -H \
	'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36' -H \
	'Content-Type: application/x-www-form-urlencoded' -H \
	'Accept: text/plain, */*; q=0.01' -H \
	'X-Requested-With: XMLHttpRequest' -H \
	'Connection: keep-alive' -H \
	'DNT: 1' --data "action=historical_data&curr_id=$STOCK_ID&st_date=01%2F01%2F2006&end_date=$D%2F$M%2F$Y&interval_sec=$PERIOD" \
	--compressed > stdout.html

TMPOUT=$(mktemp)

echo "Date,Open,High,Low,Close,Volume" > $TMPOUT
w3m -dump stdout.html | \
	grep -v Data | \
	head -n -3 | \
	awk '{ printf ("%s-%s-%s;%s;%s;%s;%s;%s\n", substr($1, 7, 4), substr($1, 4, 2), substr($1, 0, 2), $3, $4, $5, $2, $6 ) }' | \
	sed 's/,/\./g;s/\.//5g;s/M/000000/g;s/K/000/g;s/;/,/g' \
	>> $TMPOUT

echo $TMPOUT
# cat $TMPOUT
