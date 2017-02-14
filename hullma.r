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

    # HMA rule
    # print(paste("=== ", stock_name, " ==="))
    if (    
            (hma10[length(hma10)] > hma20[length(hma20)]) &&
            (hma10[length(hma10)-1] < hma20[length(hma20)-1]) 
       ) {

       	print(paste("HMA CrossOver: ", stock_name))
       	print(paste("    RSI: ", sprintf("%.2f", rsi[length(rsi)])))
		
		# check volume
        last_volume <- stock[,"Volume"][length(ema_vol)]
		last_ema_vol <- ema_vol[length(ema_vol)]

		if (last_volume > last_ema_vol) {
			rel_vol <- sprintf("%.2f", (last_volume - last_ema_vol) / last_ema_vol)
       		print(paste("    Rel. Volume: ", rel_vol))
		}

    }
}
