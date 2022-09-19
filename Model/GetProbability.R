source("Data/DataHandling.r")
source("Model/MuSgmEstimation.r")

GetForecast <- function(timemoment, dat, outcome, voldlt, iStart = 1) {
  dat <- dat[dat$selection_index == outcome, ]
  tStart <- dat$ts[iStart]
  datEx <- dat[dat$ts < tStart, ]
  dat <- dat[dat$ts >= tStart, ]
  dat$volume <- dat$back + (dat$k - 1) * dat$lay
  dat$cumvol <- cumsum(dat$volume)
  
  volmax <- max(dat$cumvol)
  print(volmax)
  vollast <- timemoment*volmax
  print(vollast)
  
  iniData <- dat[dat$ts == tStart, ]
  vol <- sum(iniData$volume)
  i <- dim(iniData)[1]  			
  
  print(paste("starting from", i))
  
  iprev <- -1
  sm <- data.frame()
  
  while (TRUE) {
    if (((dat$cumvol[i] < vol) | (dat$ts[i] == dat$ts[i + 1])) &
        (i < nrow(dat))) {
      i <- i + 1
    } 
    else {
      if (i != iprev) {
        istart <- iprev
        iend <- i
        sm <- SumData(rbind(sm, dat[(istart + 1):iend, 1:5]))
        iprev <- i   
      }
      vol <- vol + voldlt
      if (vol >= vollast) {
        if (vol >= volmax) {
          vol <- vol - voldlt
        }
        break
      }
    }
  }
  
  votes <- ToVotes(sm)
  votes$VPls[votes$VPls < 0] <- 0
  votes$VMns[votes$VMns < 0] <- 0
  emsRes <- EstimateMuSgm(votes)
  gcpRes <- GetCurrPrices(SumData(rbind(datEx[, 1:5], sm)))
  
  list(time = vol, mu = emsRes$mu, sgm = emsRes$sgm, lmd = emsRes$lmd,
       outerEqVal = emsRes$outerEqVal, lhood = emsRes$lhood,
       qPls = gcpRes$qPls, qMns = gcpRes$qMns, j = iend)
}

CalculateTableForAllEvents <- function(betstape, markets, selections) {
  event_ids <- unique(markets$e_id)
  event_names <- unique(markets$e_name)
  len <- length(event_ids) * 3
  results <- data.frame(name = character(len),
                        id = character(len),
                        selection = character(len),
                        probability = numeric(len))
  for (j in 1:length(event_names)) {
    event_id <- event_ids[j]
    parsed_name <- strsplit(event_names[j], "\\\\")[[1]]
    event_name <- parsed_name[length(parsed_name)]
    print(event_name)
    dat <- GetDataFromCSV(event_id, betstape, markets, selections)
    for (selection in 1:3) {
      forecast <- tryCatch(GetForecast(1, dat, selection, 1000, iStart = 1)$mu,
                           error = function(cond) {-1})
      print(forecast)
      results$name[(event_id-1)*3 + selection] <- event_name
      results$id[(event_id-1)*3 + selection] <- event_id
      if (selection == 1) {results$selection[(event_id-1)*3 + selection] <- "HOST WINS"}
      if (selection == 2) {results$selection[(event_id-1)*3 + selection] <- "DRAW"}
      if (selection == 3) {results$selection[(event_id-1)*3 + selection] <- "GUEST WINS"}
      results$probability[(event_id-1)*3 + selection] <- forecast
    }
  }
  results
}
