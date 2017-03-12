#!/bin/bash

function get_suffix() {

    SYMBOL=$1

    if [[ ! $( grep $SYMBOL paths.txt ) ]]; then

        curl 'https://br.investing.com/search/service/search' \
            -H 'Origin: https://br.investing.com' \
            -H 'Accept-Encoding: gzip, deflate, br' \
            -H 'Accept-Language: pt-BR,pt;q=0.8,en-US;q=0.6,en;q=0.4,es;q=0.2,it;q=0.2' \
            -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36' \
            -H 'Content-Type: application/x-www-form-urlencoded' \
            -H 'Accept: application/json, text/javascript, */*; q=0.01' \
            -H 'Referer: https://br.investing.com/equities/itausa-pn-ej-n1-technical' \
            -H 'X-Requested-With: XMLHttpRequest' \
            -H 'Connection: keep-alive' \
            -H 'DNT: 1' \
            --data "search_text=$SYMBOL&term=$SYMBOL&country_id=32&tab_id=All" --compressed -s > ./jq.in
        echo $(cat ./jq.in | jq -r ".All[0].link" | sed 's/.*\///g')";"$(cat ./jq.in | jq -r ".All[0].pair_ID")
    else
        grep $SYMBOL ./paths.txt | cut -d";" -f2,3
    fi

}

BASE_URL="http://br.investing.com/equities/"
OUTFILE=./out.html

COLS="cols"
while read ROW; do
    # URL_SUFFIX=$(echo $ROW | cut -d";" -f2)

    touch ./paths-tmp.txt
    touch ./paths.txt

    # extracting symbol
    SYMBOL=$(echo $ROW | cut -d";" -f1)
    URL_SUFFIX=$(get_suffix $SYMBOL)

    # insert in sorted list
    echo "$SYMBOL;$URL_SUFFIX" >> ./paths-tmp.txt
    sort ./paths-tmp.txt | uniq > ./paths.txt
    cp ./paths.txt ./paths-tmp.txt

done < $1
