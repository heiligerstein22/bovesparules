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

InsertMySQL = function(stock_name, check_date, reasons, last_price, gain, is_rsi_d, is_rel_vol_d,
	is_bbands_d, is_hullnear_d, is_hullcross_d, is_up_w, is_up_m, num_reasons,
	rsi_prev3, rsi_prev2, rsi_prev1, rsi, bbands_prev3, bbands_prev2, bbands_prev1,
	bbands, relative_volume, volume) {

	if(!exists("con")) {
		con <- RMySQL::dbConnect(RMySQL::MySQL(), 
			user="acoes",
			password="00acoes11",
			dbname="acoes", 
			host="localhost"
		)
	}

	on.exit(RMySQL::dbDisconnect(con))

	sql <- sprintf("
		INSERT INTO stockscreaner (stock_name, check_date, reasons, price,
			gain, is_rsi_d, is_rel_vol_d, is_bbands_d, is_hullnear_d,
			is_hullcross_d, is_up_w, is_up_m, num_reasons, rsi_prev3, rsi_prev2, rsi_prev1,
			rsi, bbands_prev3, bbands_prev2, bbands_prev1, bbands, relative_volume, volume,
			created, updated) 
		VALUES ('%s', '%s', '%s', %.4f, %.4f, %1.0f, %1.0f, %1.0f, %1.0f, %1.0f, %1.0f, %1.0f,
			 %1.0f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %1.0f, %.4f, %1.0f,
			 NOW(), NOW());",
		stock_name, check_date, reasons, last_price, gain, is_rsi_d, is_rel_vol_d,
		is_bbands_d, is_hullnear_d, is_hullcross_d, is_up_w, is_up_m, num_reasons,
		rsi_prev3, rsi_prev2, rsi_prev1, rsi, bbands_prev3, bbands_prev2, bbands_prev1,
		bbands, relative_volume, volume)


  	possibleError <- tryCatch({

		rs <- RMySQL::dbSendQuery(con, sql)
		RMySQL::dbClearResult(rs)

  	}, error = function(e) {
		print(e)
	})
	
	# print(sql)

}

# funtion to cut matrix lines by date
getStockByDate <- function(stock, last_date) {

	# retorna numero da linha com determinado valor, tail usado para mes
	# (pois em mes retorna array)
	rownum <- tail(which(grepl(last_date, stock$Date)), n = 1) + 1
	# rownum = which(grepl(last_date, stock$Date)) + 1

	# recorta linhas da matrix
	return(stock[-nrow(stock):-rownum,])

}

# args
args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
	end_date <- as.Date(args[1])
} else {
	end_date <- Sys.Date()
}

lday <- format(end_date, format="%d")
lmounth <- format(end_date, format="%m")
lyear <- format(end_date, format="%Y")

# stock list
ibov <- readLines("todas.txt")
# ibov <- readLines("ibovespa.txt")
# ibov <- readLines("ibovespa-test.txt")

for (stock_name in c(ibov)){

	#print(paste("STOCK:",stock_name))

    # reading file
    stock_filename_daily = paste("stocks/", stock_name, ".D-", Sys.Date(), sep="")
    stock_filename_weekly = paste("stocks/", stock_name, ".W-", Sys.Date(), sep="")
    stock_filename_mountly = paste("stocks/", stock_name, ".M-", Sys.Date(), sep="")

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
					".SA&a=1&b=1&c=2015&g=d&ignore=.csv", 
					# ".SA&a=1&b=1&c=2015&d=",lmounth,"&e=",lday,"&f=",lyear,"&g=d&ignore=.csv", 
					sep=""
				)
			)
			stock <- stock[nrow(stock):1,]

			stock_w <- read.csv(
				paste(
					"http://chart.finance.yahoo.com/table.csv?s=",
					stock_name,
					".SA&a=1&b=1&c=2015&g=w&ignore=.csv", 
					# ".SA&a=1&b=1&c=2015&d=",lmounth,"&e=",lday,"&f=",lyear,"&g=w&ignore=.csv", 
					sep=""
				)
			)
			stock_w <- stock_w[nrow(stock_w):1,]

			stock_m <- read.csv(
				paste(
					"http://chart.finance.yahoo.com/table.csv?s=",
					stock_name,
					".SA&a=1&b=1&c=2015&g=m&ignore=.csv", 
					# ".SA&a=1&b=1&c=2015&d=",lmounth,"&e=",lday,"&f=",lyear,"&g=m&ignore=.csv", 
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


	# print(length(args))

	# storing last price before cutting matrix
	today_price <- stock[,"Close"][nrow(stock)]

	# try necessary because of stocks with null data some days
	possibleError <- tryCatch({
		# get defined date
		if (length(args) > 0) {
			stock <- getStockByDate(stock, end_date)
			stock_m <- getStockByDate(stock, paste(lyear, "-", lmounth, "-.*", sep = ""))
		}
	}, error = function(e) e
	)

    # HMA rule
    # print(paste("=== ", stock_name, " ==="))

	# check if printable
	output <- 0
	reason <- NULL

	# check HullMA closer
	# print(((hma20[length(hma20)] - hma10[length(hma10)]) / hma10[length(hma10)]))
	HullMACloser = NULL
  	possibleError <- tryCatch({
	
		# indicators
		hma10 <- TTR::HMA(stock[,"Close"], 10)
		hma20 <- TTR::HMA(stock[,"Close"], 20)
		rsi <- TTR::RSI(stock[,"Close"], n=14, maType="WMA", wts=stock[,"Volume"])
		ema_vol <- TTR::EMA(stock[,"Volume"], 20)
		bbands.close <- TTR::BBands( stock[,"Close"], 20, "SMA", 2 )

		# check HullMA CrossOver
		HullMA = NULL
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
			is_rel_vol_d <- 1
		}

		# check BBands
		# last_bbands = bbands.close[length(bbands.close[,1])][,"pctB"]
		is_bbands_d <- 0
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
			is_bbands_d <- 1
		}

		is_rsi_d <- 0
		last_rsi <- tail(rsi, n=1)
		if (last_rsi < 30) {
			output <- output + 1
			reason <- paste(reason, "RSI")
			is_rsi_d <- 1
		}

	}, error = function(e) e
	)

	##########
	# output
	##########
	last_price <- stock[,"Close"][nrow(stock)]
	if (output > 1 && 
		(last_price > 2 && last_price < 5) &&
		(last_volume > 100000)
		) {

		print(paste("Stock Name:  ", stock_name))

		if (length(args[1]) > 0) {
			gain <- ((today_price / last_price) - 1)*100
			print(paste("Gain:        ", sprintf("%.2f%%", gain)))
		}

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
		is_hullcross_d <- 0
		if (!is.null(HullMA)) {
			print(paste(HullMA))
			is_hullcross_d <- 1
		}
		is_hullnear_d <- 0
		if (!is.null(HullMACloser)) {
			print(paste(HullMACloser, " (", sprintf("%.2f%%", HullMACloserVal), ")", sep=""))
			is_hullnear_d <- 1
		}
		is_up_m <- 0
		if (prediction_m) {
			print(paste("Confidence M:", sprintf("%.4f", confidence_m)))
			is_up_m <- 1
		}
		is_up_w <- 0
		if (prediction_w) {
			print(paste("Confidence W:", sprintf("%.4f", confidence_w)))
			is_up_w <- 1
		}
		print(paste("Reason:       ", sprintf("[%s]", output), reason, sep=""))
		print("###################################################")

		# stock_name, reasons, num_reasons, rsi_prev3, rsi_prev2, rsi_prev1, rsi, bbands_prev3, 
		# bbands_prev2, bbands_prev1, bbands, relative_volume, volume
		InsertMySQL(
			stock_name, 
			end_date, 
			reason, 
			as.numeric(last_price),
			as.numeric(gain),
			as.numeric(is_rsi_d),
			as.numeric(is_rel_vol_d),
			as.numeric(is_bbands_d), 
			as.numeric(is_hullnear_d), 
			as.numeric(is_hullcross_d), 
			as.numeric(is_up_w),
			as.numeric(is_up_m),
			as.numeric(output),
			as.numeric(rsi[length(rsi)-3]),
			as.numeric(rsi[length(rsi)-2]), 
			as.numeric(rsi[length(rsi)-1]), 
			as.numeric(rsi[length(rsi)]),
			as.numeric(last_bbands[length(bbands.close[,1])-3]),
			as.numeric(last_bbands[length(bbands.close[,1])-2]),
			as.numeric(last_bbands[length(bbands.close[,1])-1]), 
			as.numeric(last_bbands[length(bbands.close[,1])]),
			as.numeric(rel_vol), 
			as.numeric(last_volume) )

	}

}

# warnings()

print("###################################################")
print(paste("# Last Download: ", stock[,"Date"][nrow(stock)]))
print("###################################################")
