#!/bin/bash

# curl 'https://www.bussoladoinvestidor.com.br/carteira/cadastra_operacao.asp?data=30%2F01%2F17&operacao=1&tipo=1&quantidade=100&papel=CIEL3&preco=26%2C76&corretora=70161' -H \
#  'dnt: 1' -H \
#  'accept-encoding: gzip, deflate, sdch, br' -H \
#  'accept-language: pt-BR,pt;q=0.8,en-US;q=0.6,en;q=0.4,es;q=0.2,it;q=0.2' -H \
#  'upgrade-insecure-requests: 1' -H \
#  'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36' -H \
#  'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H \
#  'referer: https://www.bussoladoinvestidor.com.br/carteira/carteira_completo.asp' -H \
#  'authority: www.bussoladoinvestidor.com.br' -H \
#  'cookie: __cfduid=dcff0366ce4960efd3c93eb29c04d83981483977905; ASPSESSIONIDQCARTCRD=DAPBMJNBPPNHLADBLLELIMAE; ASPSESSIONIDQAATRCRD=AFCOBPADMIMICLOAPLDGEPEC; ASPSESSIONIDQADTRASB=CLBDHPCCHFOJDNMIGMPMBNCK; optimizelyEndUserId=oeu1487170391848r0.13814809918110216; ASPSESSIONIDSCDSTDQA=FGCDHPCCLAIHGLAMFCBGHGIM; mp_782147c59c973d4c31d5e6ad2ec6b77a_mixpanel=%7B%22distinct_id%22%3A%20%2215a4243512995-07f96831a1a398-3f73035d-15f900-15a4243512a992%22%2C%22%24initial_referrer%22%3A%20%22http%3A%2F%2Fblog.bussoladoinvestidor.com.br%2Fimposto-de-renda-em-acoes%2F%22%2C%22%24initial_referring_domain%22%3A%20%22blog.bussoladoinvestidor.com.br%22%7D; mp_mixpanel__c=1; connect.sid=s%3AHa4CC7fFmCsVYSn5msPGdDYdWHJvJD6u.xQzX%2FBTF4m6KXVZhHU3jUVYMwUcfnpEFfoJFz%2B35Z6c; SessionFarm%5FGUID=%7B042850B8%2D42EC%2D4148%2D86D7%2D2FB710E657EF%7D; ASPSESSIONIDQCBTTCQB=LECDHPCCECGLLCAJNOLAINNC; ASPSESSIONIDQCASRATA=EFCDHPCCAOKBPMMBPIJFOOEB; ASPSESSIONIDSACRQBTA=NHCDHPCCELKNLIFBHDIIMOOG; __gads=ID=a378c6b35d739faf:T=1487170384:S=ALNI_MZMB8c3fP0JaMozBg3sHxb8sEtTLA; ASPSESSIONIDSCATRBSA=ELCDHPCCJHMCJCOIHOIGMFLK; ASPSESSIONIDQACSQATB=BHDDHPCCHNEKJENJEAFPNEKI; ASPSESSIONIDQABRRBTB=LIEBJLECAJOCDMAIIJLPNPNO; __utmt=1; ASPSESSIONIDQCBTSDQB=CJEBJLECGJKDMAKOBGNGAOHC; ASPSESSIONIDQCBQRBSA=OKEBJLECHMANBOCEJACOLJME; ASPSESSIONIDQCCRTCRB=MKEBJLECNMHONHPOEPEKDIAI; ASPSESSIONIDSAARRATB=PKEBJLECLBACMAAIICHCDPMN; ASPSESSIONIDQACTSCRA=MPEBJLECLDMDJEHOMMPDMJNE; ASPSESSIONIDQACSSCQA=CPEBJLECJFFCLAMKENIENBJH; optimizelySegments=%7B%223017870206%22%3A%22false%22%2C%223024710083%22%3A%22gc%22%2C%223031270119%22%3A%22referral%22%7D; optimizelyBuckets=%7B%222855560334%22%3A%222851500099%22%7D; __utma=204041987.522003413.1483977877.1487170348.1487181757.3; __utmb=204041987.13.10.1487181757; __utmc=204041987; __utmz=204041987.1487170348.2.2.utmcsr=blog.bussoladoinvestidor.com.br|utmccn=(referral)|utmcmd=referral|utmcct=/imposto-de-renda-em-acoes/' --compressed

function cadastrar() {

	ACAO="$1"
	DATA="$2"
	QNT="$3"
	VALOR="$4"
	OP="$5"

	curl -s "https://www.bussoladoinvestidor.com.br/carteira/cad_operacao.asp?redir=&data=$DATA&operacao=$OP&quantidade=$QNT&tipo=1&papel=$ACAO&preco=$VALOR&corretora=70161&tipocorretagem=1&custos=" -H \
		'dnt: 1' -H \
		'accept-encoding: gzip, deflate, sdch, br' -H \
		'accept-language: pt-BR,pt;q=0.8,en-US;q=0.6,en;q=0.4,es;q=0.2,it;q=0.2' -H \
		'upgrade-insecure-requests: 1' -H \
		'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36' -H \
		'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H \
		'referer: https://www.bussoladoinvestidor.com.br/carteira/cadastra_operacao.asp?data=30%2F01%2F17&operacao=1&tipo=1&quantidade=100&papel=CIEL3&preco=26%2C76&corretora=70161' -H \
		'authority: www.bussoladoinvestidor.com.br' -H \
		'cookie: __cfduid=dcff0366ce4960efd3c93eb29c04d83981483977905; ASPSESSIONIDQCARTCRD=DAPBMJNBPPNHLADBLLELIMAE; ASPSESSIONIDQAATRCRD=AFCOBPADMIMICLOAPLDGEPEC; ASPSESSIONIDQADTRASB=CLBDHPCCHFOJDNMIGMPMBNCK; optimizelyEndUserId=oeu1487170391848r0.13814809918110216; ASPSESSIONIDSCDSTDQA=FGCDHPCCLAIHGLAMFCBGHGIM; mp_782147c59c973d4c31d5e6ad2ec6b77a_mixpanel=%7B%22distinct_id%22%3A%20%2215a4243512995-07f96831a1a398-3f73035d-15f900-15a4243512a992%22%2C%22%24initial_referrer%22%3A%20%22http%3A%2F%2Fblog.bussoladoinvestidor.com.br%2Fimposto-de-renda-em-acoes%2F%22%2C%22%24initial_referring_domain%22%3A%20%22blog.bussoladoinvestidor.com.br%22%7D; mp_mixpanel__c=1; connect.sid=s%3AHa4CC7fFmCsVYSn5msPGdDYdWHJvJD6u.xQzX%2FBTF4m6KXVZhHU3jUVYMwUcfnpEFfoJFz%2B35Z6c; SessionFarm%5FGUID=%7B042850B8%2D42EC%2D4148%2D86D7%2D2FB710E657EF%7D; ASPSESSIONIDQCBTTCQB=LECDHPCCECGLLCAJNOLAINNC; ASPSESSIONIDQCASRATA=EFCDHPCCAOKBPMMBPIJFOOEB; ASPSESSIONIDSACRQBTA=NHCDHPCCELKNLIFBHDIIMOOG; __gads=ID=a378c6b35d739faf:T=1487170384:S=ALNI_MZMB8c3fP0JaMozBg3sHxb8sEtTLA; ASPSESSIONIDSCATRBSA=ELCDHPCCJHMCJCOIHOIGMFLK; ASPSESSIONIDQACSQATB=BHDDHPCCHNEKJENJEAFPNEKI; ASPSESSIONIDQABRRBTB=LIEBJLECAJOCDMAIIJLPNPNO; __utmt=1; ASPSESSIONIDQCBTSDQB=CJEBJLECGJKDMAKOBGNGAOHC; ASPSESSIONIDQCBQRBSA=OKEBJLECHMANBOCEJACOLJME; ASPSESSIONIDQCCRTCRB=MKEBJLECNMHONHPOEPEKDIAI; ASPSESSIONIDSAARRATB=PKEBJLECLBACMAAIICHCDPMN; ASPSESSIONIDQACTSCRA=MPEBJLECLDMDJEHOMMPDMJNE; ASPSESSIONIDQACSSCQA=CPEBJLECJFFCLAMKENIENBJH; __utma=204041987.522003413.1483977877.1487170348.1487181757.3; __utmb=204041987.15.10.1487181757; __utmc=204041987; __utmz=204041987.1487170348.2.2.utmcsr=blog.bussoladoinvestidor.com.br|utmccn=(referral)|utmcmd=referral|utmcct=/imposto-de-renda-em-acoes/; optimizelySegments=%7B%223017870206%22%3A%22false%22%2C%223024710083%22%3A%22gc%22%2C%223031270119%22%3A%22referral%22%7D; optimizelyBuckets=%7B%222855560334%22%3A%222851500099%22%7D; optimizelyPendingLogEvents=%5B%5D' --compressed | grep erro &> /dev/null

	if [[ $? != 0 ]]; then
		echo "$1 success"
	else 
		echo "$1 failure"
	fi

}

# zerada
while read LINE; do

	# CCRO3 17/01/17 100 100 16,01 15,80 0 ZERADA
	OP=$(echo $LINE | awk '{printf "%s", $8}')
	ACAO=$(echo $LINE | awk '{printf "%s", $1}')
	DATA=$(echo $LINE | awk '{printf "%s", $2}' | sed 's/\/17$/\/2017/g;s/\/0\([1-9]\)\//\/\1\//g')
	QNT_COMPRA=$(echo $LINE | awk '{printf "%s", $3}')
	QNT_VENDA=$(echo $LINE | awk '{printf "%s", $4}')
	VALOR_COMPRA=$(echo $LINE | awk '{printf "%s", $5}')
	VALOR_VENDA=$(echo $LINE | awk '{printf "%s", $6}')

	if [[ $OP == "COMPRADA" ]]; then
		echo "$ACAO $DATA $QNT_COMPRA $VALOR_COMPRA 1"
#		cadastrar "$ACAO" "$DATA" "$QNT_COMPRA" "$VALOR_COMPRA" "1"
	elif [[ $OP == "VENDIDA" ]]; then
		echo "$ACAO $DATA $QNT_VENDA $VALOR_VENDA 2"
#		cadastrar "$ACAO" "$DATA" "$QNT_VENDA" "$VALOR_VENDA" "2"
	else
		echo "$ACAO $DATA $QNT_COMPRA $VALOR_COMPRA 1"
#		cadastrar "$ACAO" "$DATA" "$QNT_COMPRA" "$VALOR_COMPRA" "1"
		echo "$ACAO $DATA $QNT_VENDA $VALOR_VENDA 2"
#		cadastrar "$ACAO" "$DATA" "$QNT_VENDA" "$VALOR_VENDA" "2"
	fi

done<$1
