##########################################################
#
#	Usage:  
#		R --quiet --vanilla --args 2017-1-31 < hullma.r
#		R --quiet --vanilla < hullma.r
#
#	@author	Leonardo Santos <heiligerstein@gmail.com>
#
##########################################################

# supress commands in output
options(echo=FALSE)

# args
args <- commandArgs(trailingOnly = TRUE)

if (length(args) > 0) {
	end_date <- as.Date(args[1])
} else {
	end_date <- Sys.Date()
}

lday <- as.numeric(format(end_date, format="%d"))
lmounth <- as.numeric(format(end_date, format="%m")) - 1
lyear <- as.numeric(format(end_date, format="%Y"))

# stock list
ibov <- readLines("todas.txt")
# ibov <- readLines("ibovespa.txt")
# ibov <- readLines("ibovespa-test.txt")

for (stock_name in c(ibov)){

	# print(paste("STOCK:",stock_name))

    # reading file
    stock_filename_daily = paste("stocks/", stock_name, ".D-", end_date, sep="")
    stock_filename_weekly = paste("stocks/", stock_name, ".W-", end_date, sep="")
    stock_filename_mountly = paste("stocks/", stock_name, ".M-", end_date, sep="")

    if (file.exists(stock_filename_daily) 
		&& file.exists(stock_filename_weekly)
		&& file.exists(stock_filename_mountly)) {

        # reading stock locally
        stock <- dget(file=stock_filename_daily)
        stock_w <- dget(file=stock_filename_weekly)
        stock_m <- dget(file=stock_filename_mountly)

    } else {

        # download stocks from WAN

        # google
        # stock <-
        # read.csv(paste("http://www.google.com/finance/historical?q=",stock_name,"&output=csv",
        # sep=""))
        # stock <- stock[ nrow(stock):1, ]

		# daily
        # stock <- TTR::getYahooData(paste(stock_name, ".SA&g=d", sep=""), 20150101)
  		possibleError <- tryCatch({

			stock <- read.csv(
				paste(
					"http://chart.finance.yahoo.com/table.csv?s=",
					stock_name,
					".SA&a=1&b=1&c=2015&d=",lmounth,"&e=",lday,"&f=",lyear,"&g=d&ignore=.csv", 
					sep=""
				)
			)
			stock <- stock[nrow(stock):1,]

			stock_w <- read.csv(
				paste(
					"http://chart.finance.yahoo.com/table.csv?s=",
					stock_name,
					".SA&a=1&b=1&c=2015&d=",lmounth,"&e=",lday,"&f=",lyear,"&g=w&ignore=.csv", 
					sep=""
				)
			)
			stock_w <- stock_w[nrow(stock_w):1,]

			stock_m <- read.csv(
				paste(
					"http://chart.finance.yahoo.com/table.csv?s=",
					stock_name,
					".SA&a=1&b=1&c=2015&d=",lmounth,"&e=",lday,"&f=",lyear,"&g=m&ignore=.csv", 
					sep=""
				)
			)
			stock_m <- stock_m[nrow(stock_m):1,]
  		}, error = function(e) e
		)

		if(inherits(possibleError, "error")) next

		# writting to disk
        dput(stock, file=stock_filename_daily)
        dput(stock_w, file=stock_filename_weekly)
        dput(stock_m, file=stock_filename_mountly)

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

	#print(paste(hma10[length(hma10)], hma20[length(hma20)], hma10[length(hma10)-1], hma20[length(hma20)-1]))
	#print(paste(hma10[length(hma10)], hma10[length(hma10)-1], hma10[length(hma10)-2], hma10[length(hma10)-3]))
	#print(paste(hma10[length(hma10)]/hma10[length(hma10)-1], hma10[length(hma10)-1]/hma10[length(hma10)-2], hma10[length(hma10)-2]/hma10[length(hma10)-3]))

    if (    
            (hma10[length(hma10)] > hma20[length(hma20)]) &&
            (hma10[length(hma10)-1] < hma20[length(hma20)-1]) &&
			# testing HMA up tendency 
			(
				hma10[length(hma10)]/hma10[length(hma10)-1] > 1 &&
				hma10[length(hma10)-1]/hma10[length(hma10)-2] > 1 &&
				hma10[length(hma10)-2]/hma10[length(hma10)-3] > 1
			)
       ) {
		HullMA <- "HullMA:       CrossOver"
		output <- output + 1
		reason <- paste(reason, "HullCross")
	}

	# check confidence and prediction
	dt <- 0.001 						# decision threshold
	stock_m_c <- stock_m[,"Close"]
	confidence_m <- (stock_m_c[length(stock_m_c)] - stock_m_c[length(stock_m_c)-1]) / stock_m_c[length(stock_m_c)-1]
	if (confidence_m > dt) {
		prediction_m <- TRUE
		output <- output + 1
		reason <- paste(reason, "Up(M)")
	} else if (confidence_m < -dt) {
		prediction_m <- FALSE
	}
	stock_w_c <- stock_w[,"Close"]
	confidence_w <- (stock_w_c[length(stock_w_c)] - stock_w_c[length(stock_w_c)-1]) / stock_w_c[length(stock_w_c)-1]
	if (confidence_w > dt) {
		prediction_w <- TRUE
		output <- output + 1
		reason <- paste(reason, "Up(W)")
	} else if (confidence_w < -dt) {
		prediction_w <- FALSE
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
	if (
		last_bbands[length(bbands.close[,1])] < 0 ||
		last_bbands[length(bbands.close[,1])-1] < 0 ||
		last_bbands[length(bbands.close[,1])-2] < 0 ||
		last_bbands[length(bbands.close[,1])-3] < 0
	) {
		output <- output + 1
		reason <- paste(reason, "BBands")
	}

	# output
	last_price <- stock[,"Close"][length(ema_vol)]
	if (output > 1 && 
		(last_price > 2 && last_price < 5) &&
		(last_volume > 100000)
		) {
		print(paste("Stock Name:  ", stock_name))
		print(paste("Price:       ", last_price))
		print(paste("Volume:      ", sprintf("%.1f K", last_volume/1000)))
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
		if (prediction_m) {
			print(paste("Confidence M:", sprintf("%.4f", confidence_m)))
		}
		if (prediction_w) {
			print(paste("Confidence W:", sprintf("%.4f", confidence_w)))
		}
		print(paste("Reason:       ", sprintf("[%s]", output), reason, sep=""))
		print("###################################################")
	}

}
# warnings()

print("###################################################")
print(paste("# Last Download: ", stock[,"Date"][length(stock[,"Date"])-1]))
print("###################################################")
