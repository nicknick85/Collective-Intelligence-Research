## These scripts are obsolete and are provided for historicity. They allowed us to obtain our historical data from the market.
###############################################################################################################################


InitSession <- function(name, password)
{
	options(RCurlOptions = list(cainfo ="DataLoader/cacert.pem"));
	login(name, password, 82);	
}


GetFootballMarkets <- function(TimeDecr = FALSE)
{
	ms <- getAllMarkets(eventTypeIds=list(int=1));
	
	MarketIsInteresting <- (ms$"Market Name" == "Match Odds") | 
		(ms$"Market Name" == "Over/Under 2.5 Goals") | 
		(ms$"Market Name" == "Over/Under 1.5 Goals") | 
		(ms$"Market Name" == "Correct Score");
	MarketIsRegularAndActive <- (ms$"Market Type" == "O") & 
		(ms$"Bet Delay" == "0") & 
		#(ms$"BSP Market" == "N") & 
		(ms$"Exchange Id" == 1) & 
		(ms$"Market Status" == "ACTIVE");
	ms <- ms[MarketIsInteresting & MarketIsRegularAndActive, ];
	
	fc <- factor(ms$"Menu Path");
	events <- split(ms, fc);
	events <- lapply(events, function(ev){ev$"Event Date"<-max(ev$"Event Date"); ev});
	ms <- unsplit(events, fc);

	ms[order(ms$"Event Date", ms$"Menu Path", ms$"Market Name", decreasing = TimeDecr), c(1, 2, 5, 6, 14)];
}


GetMarketState <- function(
			marketId,     # identifier of the market being scanned
			selIds,       # identifiers of the selections being scanned
			eventId,      # the chosen identifier of the event
			log)          # the name of a log file
{
	mState <- data.frame();

	t <- Sys.time();

	con <- file(log, "a")
	writeLines(paste("Start data transfer for market", marketId, "at", t), con);
	close(con);

	## The following two calls take a long time. So the data
	## in [mv] and [mp] may be unharmonious.
	#################################################################

	mv <- eval(call("getMarketTradedVolumeCompressed", marketId));	
	mp <- eval(call("getCompleteMarketPricesCompressed", marketId));
	
	#################################################################

	con <- file(log, "a")
	msg <- paste("End data transfer for market", marketId, "at", t);
	if (mp[1] == "API_ERROR") msg <- paste0(msg, ", but with API_ERROR");
	writeLines(msg, con);
	close(con);

	for (sId in selIds)
	{
		pr <- mp[[as.character(sId)]]$prices;
		tam <- mp[[as.character(sId)]]$TotalAmountMatched;

		if (tam == 0)
		{
			k = pr[, 1];
			sback = pr[, 3];
			slay = pr[, 2];
			

			tst_sback = pr[, 3];
			tst_slay = pr[, 2];
			tst_ta = rep(0, length(pr[, 1]));
		}
		else
		{
			ta <- mv[[as.character(sId)]]$tradedAmounts;

			## Here we try to harmonize the data in [pr] and [ta]. 
			###########################################################
			if (is.null(dim(ta)))
				ta <- matrix(nrow = 0, ncol = 2);

			lpm <- mp[[as.character(sId)]]$LastPriceMatched;
			dlt <- tam - sum(ta[, 2]);
			
			if (sum(ta[, 1] == lpm) == 0)
			{
				ta <- rbind(ta, c(lpm, 0));
				ta <- ta[order(ta[, 1]), ];
			}
			
			ta[ta[, 1] == lpm, 2] <- ta[ta[, 1] == lpm, 2] + dlt;
			###########################################################


			isMatchedBets <- is.element(pr[, 1], ta[, 1]);
			isOpenedBets <- is.element(ta[, 1], pr[, 1]);


			tst_sback = c(pr[, 3], rep(0, length(ta[!isOpenedBets, 2])));
			tst_slay = c(pr[, 2], rep(0, length(ta[!isOpenedBets, 2])));
			tst_ta = rep(0, length(pr[, 1]));
			tst_ta[isMatchedBets] <- ta[isOpenedBets, 2];
			tst_ta <- c(tst_ta, ta[!isOpenedBets, 2]);


			pr[isMatchedBets, 2] <- pr[isMatchedBets, 2] + ta[isOpenedBets, 2]/2;
			pr[isMatchedBets, 3] <- pr[isMatchedBets, 3] + ta[isOpenedBets, 2]/2;

			k = c(pr[, 1], ta[!isOpenedBets, 1]);
			sback = c(pr[, 3], ta[!isOpenedBets, 2]/2);
			slay = c(pr[, 2], ta[!isOpenedBets, 2]/2);
		}


		sState <- data.frame(
			e_id = as.integer(eventId),
			market_id = as.integer(marketId),
			selection_id = as.integer(sId),
			ts = t,
			k = k,
			sback = sback,
			slay = slay,
			matched = NA,


			tst_dlt = NA, 
			tst_sback = tst_sback,
			tst_slay = tst_slay,
			tst_ta = tst_ta);
			if (tam != 0) sState$tst_dlt[sState$k == lpm] = dlt;	
		
		sState <- sState[order(sState$k), ]
		
		mState <- rbind(mState, sState);
	}

	mState;
}


GetMarketStateWrapper <- function(params, name, pswd, eId)
{
	source("DataLoader/DataLoader.r");
	InitSession(name, pswd);

	state <- GetMarketState(params$mId, params$selIds, eId, params$log);	

	logout();

	state;
}


StatesDifference <- function(prevState, currState, selIds)
{
	diff <- data.frame();
	prevStateEx <- data.frame();

	for (sId in selIds)
	{
		prevSelState <- prevState[prevState$selection_id == sId, ];
		currSelState <- currState[currState$selection_id == sId, ];
		
		kIsNew <- !is.element(currSelState$k, prevSelState$k);
		kIsWithdrawn <- !is.element(prevSelState$k, currSelState$k);

		if (sum(kIsNew) > 0)
		{
			prevSelStateEx <- rbind(prevSelState, data.frame(
								e_id = prevSelState$e_id[1],
								market_id = prevSelState$market_id[1],
								selection_id = as.integer(sId),
								ts = prevSelState$ts[1],
								k = currSelState$k[kIsNew],
								sback = 0,
								slay = 0,
								matched = NA,     tst_dlt = NA, tst_sback = 0, tst_slay = 0, tst_ta = 0));
			prevSelStateEx <- prevSelStateEx[order(prevSelStateEx$k), ];
		}
		else
			prevSelStateEx <- prevSelState;

		if (sum(kIsWithdrawn) > 0)
		{
			currSelStateEx <- rbind(currSelState, data.frame(
								e_id = currSelState$e_id[1],
								market_id = currSelState$market_id[1],
								selection_id = as.integer(sId),
								ts = currSelState$ts[1],
								k = prevSelState$k[kIsWithdrawn],
								sback = 0,
								slay = 0,
								matched = NA,     tst_dlt = NA, tst_sback = 0, tst_slay = 0, tst_ta = 0));
			currSelStateEx <- currSelStateEx[order(currSelStateEx$k), ];
		}
		else
			currSelStateEx <- currSelState;

				
		currSelStateEx$matched <- pmin(currSelStateEx$sback, currSelStateEx$slay) - pmin(prevSelStateEx$sback, prevSelStateEx$slay);
		currSelStateEx$sback <- currSelStateEx$sback - prevSelStateEx$sback;
		currSelStateEx$slay <- currSelStateEx$slay - prevSelStateEx$slay;

		diff <- rbind(diff, currSelStateEx);
		prevStateEx <- rbind(prevStateEx, prevSelStateEx);
	}

	diffIsSubst <- (abs(diff$sback) >= 1.0) | (abs(diff$slay) >= 1.0);
	prevStateEx[diffIsSubst, c(6,7)] <- prevStateEx[diffIsSubst, c(6,7)] + diff[diffIsSubst, c(6,7)]

	diff <- diff[diffIsSubst, ];

	list(diff = diff, currState = prevStateEx);
}


ScanMarketOnInterval <- function(
				marketId,				
				selIds,
				prevState,
				eventId,
				log, 
				interval, 
				freq = 1.0)
{
	betsTape <- data.frame();

	stopAt <- Sys.time() + interval;
	repeat
	{
		tm <- Sys.time();		
		if (tm >= stopAt) break;
	
		currState <- tryCatch(
			GetMarketState(marketId, selIds, eventId, log), 
			error = function(e) 
				{ 
					con <- file(log, "a")
					writeLines(paste("Data transfer failed for market", marketId, "at", tm), con);
					close(con);

					prevState; 
				});
		stDiffRes <- StatesDifference(prevState, currState, selIds);

		betsTape <- rbind(betsTape, stDiffRes$diff);
		prevState <- stDiffRes$currState;

		dt <- freq - as.double(difftime(Sys.time(), tm, units = "sec"));
		if (dt > 0) Sys.sleep(dt); 

		#delays <- c(delays, dt);
	}

	list(
		BetsTape = betsTape, 
		CurrState = stDiffRes$currState);
}


ScanMarketOnIntervalWrapper <- function(params, name, pswd, eId, interval)
{
	source("DataLoader/DataLoader.r");
	InitSession(name, pswd);

	scanRes <- ScanMarketOnInterval(params$mId, params$selIds, params$prevState, eId, params$log, interval);	

	logout();

	scanRes;
}


GetMarketInfo <- function(
			marketRow,      # A row in the table returned by "GetFootballMarkets"
			marketIndex,	# 1 --- Match Odds; 2 --- Total 2.5; 3 --- Correct Score; 4 --- Total 1.5;
			eventId,
			log)
{
	mId <- marketRow$"Market ID";
	
	market <- data.frame(
		e_id = as.integer(eventId), 
		e_name = marketRow$"Menu Path",
		market_id = as.integer(mId), 
		market_name = marketRow$"Market Name",
		market_index = as.integer(marketIndex));

	m <- eval(call("getMarket", mId));		
	rs <- m$runners;	
	selections <- data.frame(
		e_id = as.integer(eventId),
		market_id = as.integer(mId),
		selection_id = as.integer(rs$selectionId),
		selection_name = rs$name,
		selection_index = index(rs$selectionId),
		win_flag = as.integer(0));

	currState <- GetMarketState(mId, rs$selectionId, eventId, log);

	list(
		Market = market, 
		Selections = selections, 
		CurrState = currState,
		SelIds = rs$selectionId);
}


GetMarketInfoWrapper <- function(mId, name, pswd, ms, eId)
{
	source("DataLoader/DataLoader.r");
	InitSession(name, pswd);
	
	m <- ms[ms$"Market ID" == mId, ];

	if (m$"Market Name" == "Match Odds") mIndex = 1; 
	if (m$"Market Name" == "Over/Under 2.5 Goals") mIndex = 2;
	if (m$"Market Name" == "Over/Under 1.5 Goals") mIndex = 4;
	if (m$"Market Name" == "Correct Score") mIndex = 3;

	log <- paste0("DataLoader/log", mIndex, ".txt");

	info <- GetMarketInfo(m, mIndex, eId, log);

	logout();

	c(info, list(Log = log));
}


ScanEvent <- function(name, password, footballMarkets, eventName, eventId, stopAt = NA)
{
	library(parallel);

	ms <- footballMarkets[footballMarkets$"Menu Path" == eventName, ];

	if (is.na(stopAt))
		stopAt = ms$"Event Date"[1] - 20;

	cl <- makeCluster(getOption("cl.cores", 4));
	parRes <- parLapply(cl, ms$"Market ID", GetMarketInfoWrapper, name = name, pswd = password, ms = ms, eId = eventId);
	stopCluster(cl);
	
	markets <- rbind(parRes[[1]]$Market, parRes[[2]]$Market, parRes[[3]]$Market, parRes[[4]]$Market);
	selections <- rbind(parRes[[1]]$Selections, parRes[[2]]$Selections, parRes[[3]]$Selections, parRes[[4]]$Selections);
	betsTape <- rbind(parRes[[1]]$CurrState, parRes[[2]]$CurrState, parRes[[3]]$CurrState, parRes[[4]]$CurrState);

	params <- list(
		list(mId = ms$"Market ID"[1], selIds = parRes[[1]]$SelIds, prevState = parRes[[1]]$CurrState, log = parRes[[1]]$Log),
		list(mId = ms$"Market ID"[2], selIds = parRes[[2]]$SelIds, prevState = parRes[[2]]$CurrState, log = parRes[[2]]$Log),
		list(mId = ms$"Market ID"[3], selIds = parRes[[3]]$SelIds, prevState = parRes[[3]]$CurrState, log = parRes[[3]]$Log),
		list(mId = ms$"Market ID"[4], selIds = parRes[[4]]$SelIds, prevState = parRes[[4]]$CurrState, log = parRes[[4]]$Log));

	repeat
	{
		tm <- Sys.time();
		remTm <- as.double(difftime(stopAt, tm, units = "sec"));
		
		if (remTm <= 0) break;

		interval <- min(5*60, remTm);

		con <- file("DataLoader/log.txt", "a");
		writeLines(paste("Scanning on the interval started at", tm), con);
		close(con);
	
		cl <- makeCluster(getOption("cl.cores", 4), timeout = 6*60);		
		parRes <- tryCatch(
			parLapply(cl, params, ScanMarketOnIntervalWrapper, name = name, pswd = password, eId = eventId, interval = interval), 
			error = function(e) 
				{ 
					con <- file("DataLoader/log.txt", "a");
					writeLines(paste("A worker did not respond at", tm + 6*60), con);
					close(con);

					list(
						list(BetsTape = data.frame(), CurrState = parRes[[1]]$CurrState),
						list(BetsTape = data.frame(), CurrState = parRes[[2]]$CurrState),
						list(BetsTape = data.frame(), CurrState = parRes[[3]]$CurrState),
						list(BetsTape = data.frame(), CurrState = parRes[[4]]$CurrState)); 
				});
		tryCatch(stopCluster(cl), error = function(e) { });

		betsTape <- rbind(betsTape, parRes[[1]]$BetsTape, parRes[[2]]$BetsTape, parRes[[3]]$BetsTape, parRes[[4]]$BetsTape);
		params[[1]]$prevState <- parRes[[1]]$CurrState;
		params[[2]]$prevState <- parRes[[2]]$CurrState;
		params[[3]]$prevState <- parRes[[3]]$CurrState;
		params[[4]]$prevState <- parRes[[4]]$CurrState;
	}

	finalState <- rbind(parRes[[1]]$CurrState, parRes[[2]]$CurrState, parRes[[3]]$CurrState, parRes[[4]]$CurrState);

	cl <- makeCluster(getOption("cl.cores", 4));
	parRes <- parLapply(cl, params, GetMarketStateWrapper, name = name, pswd = password, eId = eventId);
	stopCluster(cl);

	trueFinalState <- do.call("rbind", parRes);
	
	list(
		Markets = markets,
		Selections = selections,
		BetsTape = betsTape,
		FinalState = finalState,
		TrueFinalState = trueFinalState);
}


CleanData <- function(data)
{
	data$BetsTape$sback[abs(data$BetsTape$sback) < 1.0e-8] <- 0;
	data$BetsTape$slay[abs(data$BetsTape$slay) < 1.0e-8] <- 0;
	data$BetsTape$matched[abs(data$BetsTape$matched) < 1.0e-8] <- 0;
	
	data;
}


SumData <- function(data)
{
	bt <- data$BetsTape;
	btSplit <- split(bt, list(factor(bt$market_id), factor(bt$selection_id), factor(bt$k)), drop = TRUE);
	btSplitSum <- lapply(btSplit, function(kdata) 
					{
						ksum<-kdata[1,]; 
						ksum$slay[1] <- sum(kdata$slay); 
						ksum$sback[1] <- sum(kdata$sback); 
						ksum;
					});
	btSum <- do.call("rbind", btSplitSum);
	btSum <- btSum[order(btSum$market_id, as.integer(btSum$selection_id), btSum$k), ];

	btSum;
}


TestData <- function(data)
{
	btSum <- SumData(data);
#print(data$FinalState);
	stDiff <- StatesDifference(btSum, data$TrueFinalState, data$Selections$selection_id)$diff
	stDiff$sback[abs(stDiff$sback) < 1.0e-8] <- 0;
	stDiff$slay[abs(stDiff$slay) < 1.0e-8] <- 0;
	stDiff[abs(stDiff$sback >= 1.0) | abs(stDiff$slay) >= 1.0, ];	
}


SaveData <- function(data, pswd, user = "postgres")
{
	library(RPostgreSQL);

	drv <- dbDriver("PostgreSQL");
	con <- dbConnect(drv, user = user, password = pswd, dbname = "bfhist_time");
	
	if (dbExistsTable(con, "tickdata_markets"))
		dbWriteTable(con, "tickdata_markets", value = data$Markets, append = TRUE, row.names = FALSE)
	else
		dbWriteTable(con, "tickdata_markets", value = data$Markets, row.names = FALSE);

	if (dbExistsTable(con, "tickdata_selections"))
		dbWriteTable(con, "tickdata_selections", value = data$Selections, append = TRUE, row.names = FALSE)
	else
		dbWriteTable(con, "tickdata_selections", value = data$Selections, row.names = FALSE);

	if (dbExistsTable(con, "tickdata_betstape"))
		dbWriteTable(con, "tickdata_betstape", value = data$BetsTape[, 1:8], append = TRUE, row.names = FALSE)
	else
		dbWriteTable(con, "tickdata_betstape", value = data$BetsTape[, 1:8], row.names = FALSE);

	dbDisconnect(con);
}