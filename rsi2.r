##########################################################
#
#	Usage:  
#		R --quiet --vanilla --args 2017-1-31 < rsi2.r
#		R --quiet --vanilla < rsi2.r
#
#	@author	Leonardo Santos <heiligerstein@gmail.com>
#
##########################################################

# supress commands in output
options(echo=FALSE)

# stock list
ibov <- readLines("todas.txt")
# ibov <- readLines("ibovespa.txt")
# ibov <- readLines("ibovespa-test.txt")

InsertMySQL = function(stock_name,buy_price,sell_price,stop_loss,rsi2,buy_date,sell_date,gain,duration,
	evolution, volume)
{

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
		INSERT INTO backtest (stock_name,buy_price,sell_price,stop_loss,rsi2,
			buy_date,sell_date,gain,duration,evolution,volume,created,updated) 
		VALUES ('%s', %.4f, %.4f, %.4f, %.4f, '%s', '%s', %.4f, %1.0f, %4.f, %1.0f, NOW(), NOW());",
		stock_name,buy_price,sell_price,stop_loss,rsi2,buy_date,sell_date,gain,duration,evolution,volume)

  	possibleError <- tryCatch({

		rs <- RMySQL::dbSendQuery(con, sql)
		RMySQL::dbClearResult(rs)

  	}, error = function(e) {
		print(e)
	})
	
	# print(sql)

}

# checks if this day was analyzed
checkStockScreenerMySQL = function(stock_name, check_date) {

	if(!exists("con")) {
		con <- RMySQL::dbConnect(RMySQL::MySQL(), 
			user="acoes",
			password="00acoes11",
			dbname="acoes", 
			host="localhost"
		)
	}
	on.exit(RMySQL::dbDisconnect(con))

	rs <- RMySQL::dbSendQuery(con, sprintf("SELECT COUNT(*) as count
				FROM stockscreaner 
				WHERE stock_name = '%s'
				AND check_date = '%s';", 
			stock_name, check_date))
	
	data <- RMySQL::fetch(rs, n=1)

	if (data[,"count"] == 1) {
		return(TRUE)
	} else {
		return(FALSE)
	}
	
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

getCSVBrInvesting <- function(stock_name, period) {
	csv_file <- try(
		system(
			paste("./brinvesting_to_csv.sh", stock_name, period), 
			intern = TRUE
		)
	)
	return(read.csv(csv_file))
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

# returns the last workdate
# this evicts to download unwanted files 
last_workdate_filename <- "last_workdate.dat"
getLastWorkDate = function() {

	if (file.exists(last_workdate_filename)) {
		last_workdate <- dget(file=last_workdate_filename)
		# print("ENTREI 1")
		return(last_workdate)
	}

	stock <- getCSVBrInvesting("PETR4", "Daily")

	# loop to find last valid workdate with volume
	for (i in (1:nrow(stock))) {
		if (stock[i,"Volume"] > 0) {
			last_workdate <- stock[i,"Date"]
			dput(last_workdate, file=last_workdate_filename)
			return(last_workdate)
		}
	}

}

last_workdate <- getLastWorkDate()
print(last_workdate)
old_stock <- NULL

for (stock_name in c(ibov)){

	# print(paste("STOCK:",stock_name))

    # reading file
    stock_filename_daily = paste("stocks/", stock_name, ".D-", last_workdate, sep="")

    if (file.exists(stock_filename_daily)) {

        # reading stock locally
        stock <- dget(file=stock_filename_daily)

    } else {

        # download stocks from WAN

  		possibleError <- tryCatch({

			stock <- getCSVBrInvesting(stock_name, "Daily")
			stock <- stock[nrow(stock):1,]

  		}, error = function(e) e
		)

		if(inherits(possibleError, "error")) next

		# writting to disk
        dput(stock, file=stock_filename_daily)

    }

	# jump to next loop
	if (identical(old_stock, stock)) {
		print("next")
		next
	}
	old_stock <- stock

	# storing last price before cutting matrix
	today_price <- stock[,"Close"][nrow(stock)]

	# try necessary because of stocks with null data some days
	possibleError <- tryCatch({
		# get defined date
		if (length(args) > 0) {
			stock <- getStockByDate(stock, end_date)
		}
	}, error = function(e) e
	)

  	possibleError <- tryCatch({

		# params
		max_duration <- 10000
		stop_perc <- 1.3
		rsi2_limit <- 10
		sell_below <- 0.01
		initial_value <- 10000
		
		# indicators
		rsi2 <- TTR::RSI(stock[,"Close"], n=2, wts=stock[,"Volume"])
		ma200 <- TTR::SMA(stock[,"Close"], 200)

    	# loop to find last valid workdate with volume
		j <- 1
		operation <- 2 # 1 = buy, 2 = sell
		buy_price <- NULL
		sell_price <- NULL
		buy_date <- NULL
		sell_date <- NULL
		duration <- 0
		stop_loss <- 0
		evolution <- initial_value
		
    	for (i in (1:nrow(stock))) {

			# sell
			max_last2 <- max(stock[i-1,"High"], stock[i-2,"High"])
			if (!is.null(buy_date)) {
				duration <- as.numeric(difftime(stock[i,"Date"], buy_date, units="days"))
			}
			
			if (operation == 1 && (stock[i,"High"] >=  max_last2 - sell_below || duration >= max_duration || stock[i,"Close"] < stop_loss)) {
			# if (operation == 1 && (stock[i,"High"] >=  max_last2 - 0.02 || stock[i,"Close"] < stop_loss)) {

				sell_date <- stock[i,"Date"]
				if (stock[i,"High"] >=  max_last2 - sell_below) {
					sell_price <- max(max_last2 - sell_below, stock[i,"Low"])
#					print("Condition")
				}
				if (duration >= max_duration) {
					sell_price <- stock[i,"Close"]
#					print("Duration")
				}
				if (stock[i,"Close"] < stop_loss) {
					sell_price <- stop_loss
#					print("Stop")
				}

				gain <- ((sell_price / buy_price)-1)*100

				print(paste(j, buy_date, sell_date, stock_name, ", buy:", buy_price, ", sell:",
					sell_price, ", gain:", gain, ", duration:", duration))

				evolution <- evolution * (1 + gain/100)

				InsertMySQL(stock_name,buy_price,sell_price,stop_loss,rsi2[i],buy_date,sell_date,gain,duration,evolution,stock[i,"Volume"])

				operation <- 2
			}
				
			# buy
			if (!is.na(rsi2[i]) && !is.na(ma200[i])) {
					
				stop_loss <- stock[i,"Close"] - ((stock[i,"High"] - stock[i,"Low"])*stop_perc)
				# stop_loss_perc <- ((stock[i,"Close"] / stop_loss) - 1) * 100
			
				# if (operation == 2 && rsi2[i] < rsi2_limit && stock[i,"Close"] > ma200[i] && stop_loss_perc < 5) {
				if (operation == 2 && rsi2[i] < rsi2_limit && stock[i,"Close"] > ma200[i]) {
					buy_price <- stock[i,"Close"]
					buy_date <- stock[i,"Date"]
					# stop_loss <- stock[i,"Close"] - ((stock[i,"High"] - stock[i,"Low"])*stop_perc)
					# print(paste(j, stock[i,"Date"], stock_name, rsi2[i], ", buy:", buy_price))
					j <- j + 1
					operation <- 1
				}

			}

    	}


	}, error = function(e) e
	)

}

warnings()
