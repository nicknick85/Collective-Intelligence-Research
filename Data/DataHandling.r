## Scripts for uploading the PostgreSQL data into R and for further working with them. 
## Author: N.N.Osipov
#######################################################################################


library(RPostgreSQL);


### "GetData" extracts the data from the database.
###################################################

GetData <- function(
		e_id,                   # Identifier of event
		dbname,                 # Database name
		pswd,                   # Database password
		user = "postgres")      # Database user	
{
	drv <- dbDriver("PostgreSQL");
	con <- dbConnect(drv, user = user, password = pswd, dbname = dbname);

	query <- paste(
			"select t.selection_index, b.ts, b.k, b.back, b.lay, b.matched", 
			"from (select m.e_id, m.market_id, s.selection_id, s.selection_index from tickdata_markets m left join tickdata_selections s on m.e_id = s.e_id AND m.market_id = s.market_id where m.e_id =",
			e_id,
			"and m.market_index = 1) t",
			"left join tickdata_betstape b on t.e_id = b.e_id AND t.market_id = b.market_id AND t.selection_id = b.selection_id");	

	qRes <- dbSendQuery(con, query);
	data <- fetch(qRes, -1);	
	data <- data[order(data$selection_index, data$ts, data$k),]
	
	dbDisconnect(con);

	data;	
}


### "SumData" aggregates the data by time.
###########################################

SumData <- function(
		bt)  # "bets tape"
{
	btSplit <- split(bt, list(factor(bt$selection_index), factor(bt$k)), drop = TRUE);
	btSplitSum <- lapply(btSplit, function(kdata) 
					{
						ksum<-kdata[1,]; 
						ksum$lay[1] <- sum(kdata$lay); 
						ksum$back[1] <- sum(kdata$back); 
						ksum;
					});
	btSum <- do.call("rbind", btSplitSum);
	btSum <- btSum[order(as.integer(btSum$selection_index), btSum$k), ];

	btSum$back[abs(btSum$back) < 1.0e-8] <- 0;
	btSum$lay[abs(btSum$lay) < 1.0e-8] <- 0;
	#btSum$matched[abs(btSum$matched) < 1.0e-8] <- 0;

	btSum[, 1:5];
}


### "ToVotes" converts aggregated data to the format using in the article.
############################################################################

ToVotes <- function(
		selData) # Usually, it contains aggregated data for one of selections (win of a certain team, a draw, etc.).
{
	data.frame(
		q = 1 / selData$k,
		VPls = selData$back,
		VMns = (selData$k - 1) * selData$lay);
}

############################################################################

VtoS <- function(votes)
{
	data.frame(
		q = votes$q,
		SPls = votes$VPls / votes$q,
		SMns = votes$VMns / (1 - votes$q));
}


AggData <- function(dat, outcome, time)
{
	S <- VtoS(ToVotes(SumData(dat[dat$selection_index == outcome & dat$ts <= min(dat$ts) + time, ])));
	S[order(S$q), ];
}