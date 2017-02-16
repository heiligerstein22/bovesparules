#!/bin/bash

# ABEV3 18/01/17 200 0 17,35 0,00 200 COMPRADA
# ABEV3 27/01/17 0 200 0,00 17,03 200 VENDIDA
# CCRO3 17/01/17 100 100 16,01 15,80 0 ZERADA

if [[ $# -lt 1 || ! -f $1 ]]; then
	echo "Usage: $0 dados_bovespa.txt"
	exit 2
fi

awk '{
		if ($8 == "COMPRADA") {
			if ($8 == last_action) {
				printf "\n"
			}
			printf "%s\t%s\t%s\t%s\t", $2, $1, $3, $5
		} else if ($8 == "VENDIDA") {
			printf "%s\t%s\n", $2, $6
		} else {
			printf "%s\t%s\t%s\t%s\t%s\t%s\n", $2, $1, $3, $5, $2, $6
		}
		last_action = $8
	} END { 
		printf "\n"
	}' \
	$1
