ibov <- readLines("ibovespa.txt")

# stock <- TTR::getYahooData("PETR3.SA", 20150101)
# tail(hma10, n=1) > tail(hma20, n=1) && tail(hma10, n=2) < tail(hma20, n=2)
# (hma10[length(hma10)] > hma20[length(hma20)]) && (hma10[length(hma10)-1] < hma20[length(hma20)-1])

for (stock_name in c(ibov)){

    # reading file
    stock_filename_daily = paste("stocks/", stock_name, ".D", sep="")
    stock_filename_weekly = paste("stocks/", stock_name, ".W", sep="")

    if (file.exists(stock_filename_daily) && file.exists(stock_filename_weekly)) {

        # reading stock locally
        stock <- dget(file=stock_filename_daily)
        stock_w <- dget(file=stock_filename_weekly)

    } else {

        # download stocks from WAN

		# daily
        # stock <- TTR::getYahooData(paste(stock_name, ".SA&g=d", sep=""), 20150101)
		stock <- read.csv(
			paste(
				"http://chart.finance.yahoo.com/table.csv?s=",
				stock_name,
				".SA&a=1&b=1&c=2015&g=d&ignore=.csv", 
				sep=""
			)
		)
		stock <- stock[nrow(stock):1,]

		stock_w <- read.csv(
			paste(
				"http://chart.finance.yahoo.com/table.csv?s=",
				stock_name,
				".SA&a=1&b=1&c=2015&g=w&ignore=.csv", 
				sep=""
			)
		)
		stock_w <- stock[nrow(stock_w):1,]

		# writting to disk
        dput(stock, file=stock_filename_daily)
        dput(stock_w, file=stock_filename_weekly)

    }

	# indicators
    hma10 <- TTR::HMA(stock[,"Close"], 10)
    hma20 <- TTR::HMA(stock[,"Close"], 20)
    rsi <- TTR::RSI(stock[,"Close"], n=14, maType="WMA", wts=stock[,"Volume"])
	ema_vol <- TTR::EMA(stock[,"Volume"], 20)
	bbands.close <- TTR::BBands( stock[,"Close"], 20, "SMA", 2 )

    # HMA rule
    # print(paste("=== ", stock_name, " ==="))

	# check if printable
	output <- 0
	reason <- NULL

	# check HullMA CrossOver
	HullMA = NULL
    if (    
            (hma10[length(hma10)] > hma20[length(hma20)]) &&
            (hma10[length(hma10)-1] < hma20[length(hma20)-1]) 
       ) {
		HullMA <- "HullMA:       CrossOver"
		output <- output + 1
		reason <- paste(reason, "HullCross")
	}

	# check HullMA closer
	# print(((hma20[length(hma20)] - hma10[length(hma10)]) / hma10[length(hma10)]))
	HullMACloser = NULL
	HullMACloserVal = ((hma20[length(hma20)] - hma10[length(hma10)]) / hma20[length(hma20)])*100
	# print(HullMACloser)
    if (HullMACloserVal >= 0 && HullMACloserVal < 0.3) {
		HullMACloser <- "HullMA:       Closer"
		output <- output + 1
		reason <- paste(reason, "HullNear")
	}

	# check volume
	last_volume <- stock[,"Volume"][length(ema_vol)]
	last_ema_vol <- ema_vol[length(ema_vol)]
	rel_vol_val <- (last_volume - last_ema_vol) / last_ema_vol
	rel_vol <- sprintf("%.2f", rel_vol_val)
	# if (last_volume > last_ema_vol) {
	if (rel_vol_val > 1) {
		output <- output + 1
		reason <- paste(reason, "Volume")
	}

	# check BBands
	# last_bbands = bbands.close[length(bbands.close[,1])][,"pctB"]
	last_bbands = bbands.close[,"pctB"]
	# if (last_bbands[length(bbands.close[,1])] > 1 || last_bbands[length(bbands.close[,1])] < 0) {
	if (last_bbands[length(bbands.close[,1])] < 0) {
		output <- output + 1
		reason <- paste(reason, "BBands")
	}

	# output
	if (output) {
		print(paste("Stock Name:  ", stock_name))
		print(paste("Rel. Volume: ", rel_vol))
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
			print(paste(HullMA))
		}
		if (!is.null(HullMACloser)) {
			print(paste(HullMACloser, " (", sprintf("%.2f%%", HullMACloserVal), ")", sep=""))
		}
		print(paste("Reason:       ", sprintf("[%s]", output), reason, sep=""))
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
