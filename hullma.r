ibov <- readLines("ibovespa.txt")

# stock <- TTR::getYahooData("PETR3.SA", 20150101)
# tail(hma10, n=1) > tail(hma20, n=1) && tail(hma10, n=2) < tail(hma20, n=2)
# (hma10[length(hma10)] > hma20[length(hma20)]) && (hma10[length(hma10)-1] < hma20[length(hma20)-1])

for (stock_name in c(ibov)){

    # reading file
    stock_filename = paste("stocks/", stock_name, sep="")
    if (file.exists(stock_filename)) {

        # reading stock locally
        stock <- dget(file=stock_filename)

    } else {

        # download stocks from WAN
        stock <- TTR::getYahooData(paste(stock_name,".SA", sep=""), 20150101)
        dput(stock, file=stock_filename)

    }

    hma10 <- TTR::HMA(stock[,"Close"], 10)
    hma20 <- TTR::HMA(stock[,"Close"], 20)
    rsi <- TTR::RSI(stock[,"Close"], n=14, maType="WMA", wts=stock[,"Volume"])
	ema_vol <- TTR::EMA(stock[,"Volume"], 20)
	bbands.close <- TTR::BBands( stock[,"Close"], 20, "SMA", 2 )

    # HMA rule
    # print(paste("=== ", stock_name, " ==="))

	# check if printable
	output <- 0

	# check HullMA CrossOver
	HullMA = NULL
    if (    
            (hma10[length(hma10)] > hma20[length(hma20)]) &&
            (hma10[length(hma10)-1] < hma20[length(hma20)-1]) 
       ) {
		HullMA <- "HullMA Cross"
		output <- 1
	}

	# check volume
	last_volume <- stock[,"Volume"][length(ema_vol)]
	last_ema_vol <- ema_vol[length(ema_vol)]
	if (last_volume > last_ema_vol) {
		output.rel_vol <- sprintf("%.2f", (last_volume - last_ema_vol) / last_ema_vol)
	}

	# check BBands
	# last_bbands = bbands.close[length(bbands.close[,1])][,"pctB"]
	last_bbands = bbands.close[,"pctB"]
	if (last_bbands[length(bbands.close[,1])] > 1 || last_bbands[length(bbands.close[,1])] < 0) {
	# if (last_bbands[length(bbands.close[,1])] < 0) {
		output <- 1
	}

	# output
	if (output) {
		print(paste("Stock Name:  ", stock_name))
		print(paste("Rel. Volume: ", output.rel_vol))
		print(paste("BBands:      ", 
					sprintf("%.2f [last: %.2f, %.2f, %.2f]", 
					last_bbands[length(bbands.close[,1])], 
					last_bbands[length(bbands.close[,1])-1], 
					last_bbands[length(bbands.close[,1])-2], 
					last_bbands[length(bbands.close[,1])-3]
				)
			)
		)
       	print(paste("RSI:         ", 
				sprintf("%.2f [last: %.2f, %.2f, %.2f]", 
					rsi[length(rsi)], 
					rsi[length(rsi)-1], 
					rsi[length(rsi)-2], 
					rsi[length(rsi)-3]
				)
			)
		)
		if (!is.null(HullMA)) {
			print(paste(HullMA, ": OK"))
		}
		print("")
	}

#    if (    
#            (hma10[length(hma10)] > hma20[length(hma20)]) &&
#            (hma10[length(hma10)-1] < hma20[length(hma20)-1]) 
#       ) {
#
#       	print(paste("HMA CrossOver: ", stock_name))
#       	print(paste("    RSI: ", sprintf("%.2f", rsi[length(rsi)])))
#		
#		# check volume
#       last_volume <- stock[,"Volume"][length(ema_vol)]
#		last_ema_vol <- ema_vol[length(ema_vol)]
#
#		if (last_volume > last_ema_vol) {
#			rel_vol <- sprintf("%.2f", (last_volume - last_ema_vol) / last_ema_vol)
#       		print(paste("    Rel. Volume: ", rel_vol))
#		}
#    }

}
