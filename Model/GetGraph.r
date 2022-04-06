## Scripts for obtaining graphs of mu and sigma estimates where "time" is the aggregated V^+ and V^-. 
## Author: A.V.Osipov
######################################################################################################


source("Data/DataHandling.r")
source("Model/MuSgmEstimation.r")
source("Model/PlotGraph.r")


GetCurrPrices <- function(
	sumData)  # Summed data for one of the selections
{
	bestForLay <- sumData$k[sumData$back > sumData$lay + 1][1];
	l <- length(sumData$k[sumData$back + 1 < sumData$lay]);
	bestForBack <- sumData$k[sumData$back + 1 < sumData$lay][l];

	data.frame(qPls = 1/bestForBack, qMns = 1/bestForLay);
}


GetGraphOperTime <- function(dat, outcome, voldlt, iStart = 1, withlog = TRUE) 
{
	dat <- dat[dat$selection_index == outcome, ]
	tStart <- dat$ts[iStart]
	datEx <- dat[dat$ts < tStart, ]
	dat <- dat[dat$ts >= tStart, ]
	dat$volume <- dat$back + (dat$k - 1) * dat$lay
	dat$cumvol <- cumsum(dat$volume)
	volmax <- max(dat$cumvol)
	
	print(volmax)

  	iniData <- dat[dat$ts == tStart, ]
	vol <- sum(iniData$volume);  		
  	i <- dim(iniData)[1]  			

	len <- 1 + (volmax - vol) %/% voldlt
	print(len)
	gr <- data.frame(time = rep(NA, len), 
                   mu = rep(NA, len), 
                   sgm = rep(NA, len), 
                   lmd = rep(NA, len),
                   outerEqVal = rep(NA, len),
                   lhood = rep(NA, len), 
                   qPls = rep(NA, len),
                   qMns = rep(NA, len), 
                   i = rep(NA, len))
 
 

	print(paste("starting from", i))

	iprev <- -1
	sm <- data.frame()
	j <- 1
  
	while (j <= len) 
	{
		if (vol > volmax) 
		{
			print(c(vol, volmax, j)); 
			break
		}
    
		if (((dat$cumvol[i] < vol) | (dat$ts[i] == dat$ts[i + 1])) & (i < nrow(dat))) 
		{
      			i <- i + 1
    		} 
		else 
		{
			if (withlog) 
			{
        			print(paste("time ", j, "volume ", vol, "real volume", dat$cumvol[i]))
			}
			
			if (iprev != i) 
			{
				sm <- SumData(rbind(sm, dat[(iprev + 1):i, 1:5]))
								
				votes <- ToVotes(sm)
				votes$VPls[votes$VPls < 0] <- 0
				votes$VMns[votes$VMns < 0] <- 0
				
				emsRes <- EstimateMuSgm(votes)
				gcpRes <- GetCurrPrices(SumData(rbind(datEx[, 1:5], sm)))
				
				iprev <- i        
			}
      								
			gr$time[j] <- vol
			gr$mu[j] <- emsRes$mu
			gr$sgm[j] <- emsRes$sgm
			gr$lmd[j] <- emsRes$lmd
			gr$outerEqVal[j] <- emsRes$outerEqVal
			gr$lhood[j] <- emsRes$lhood
			gr$qPls[j] <- gcpRes$qPls
			gr$qMns[j] <- gcpRes$qMns
			
			gr$i[j] <- i
			vol <- vol + voldlt
			j <- j + 1
		}
	}

	gr
}

PlotMuSgmById <- function(evt_id, betstape, markets, selections) {
  dat <- GetDataFromCSV(evt_id, betstape, markets, selections)
  gr <- GetGraphOperTime(dat, 1, 1000)
  PlotMuSgm(gr)
}
