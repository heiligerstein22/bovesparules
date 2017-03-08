#!/bin/bash

LAST_WORKDATE="last_workdate.dat"
MYDATE=$(date +%Y-%m-%d)
I=0

rm -f $LAST_WORKDATE

while [[ $MYDATE != "2017-01-01" ]]; do

	MYDATE=$(date -d -${I}day +%Y-%m-%d)

	echo $MYDATE

	R --quiet --vanilla --args "${MYDATE}" < hullma.r

	let I--
	
done

