## Scripts for simulation of our voting model. 
## Author: N.N.Osipov
###############################################


source("Model/MuSgmEstimation.r")


### Expected utility of a matched vote for $\omega = 1$.
#########################################################

UFor1 <- function(p, q, lmd)
{
	p * (1 - exp(-lmd)) / (1 - exp(-lmd * q))
}


### Expected utility of a matched vote against $\omega = 1$ (for $\omega = 0$).
################################################################################

UFor0 <- function(p, q, lmd)
{
	UFor1(1 - p, 1 - q, lmd)      #### (1 - p) * (1 - exp(-lmd)) / (1 - exp(-lmd * (1 - q)))
}


### Model of voting for a single coefficient.
##############################################

VModelForCoeff <- function(
		q,         # Voting coefficient.
		lmd,
		pp,        # Sequence of beliefs.
		rhoPls,    # Model probability of matching of an unmatched vote for $\omega = 1$. 
		rhoMns,    # Model probability of matching of an unmatched vote against $\omega = 1$ (for $\omega = 0$).
		log = FALSE)
{
	VPls <- 0;
	VMns <- 0;

	if (log) print (c('SPls ', 'SMns'), quote = FALSE);

	for (p in pp)
	{
		if ((1 - q) * VPls ==  q * VMns)
		{
			if (rhoPls * UFor1(p, q, lmd) + (1 - rhoPls) >= rhoMns * UFor0(p, q, lmd) + (1 - rhoMns))
			{
				VPls <- VPls + 1;
			}
			else
			{
				VMns <- VMns + 1;
			}
		}
		
		else if ((1 - q) * VPls >=  q * VMns)
		{
			if (rhoPls * UFor1(p, q, lmd) + (1 - rhoPls) >= UFor0(p, q, lmd))
			{
				VPls <- VPls + 1;
			}
			else
			{
				VMns <- VMns + 1;
			}
		}
			
		else if (UFor1(p, q, lmd) <= rhoMns * UFor0(p, q, lmd) + (1 - rhoMns))
		{
			VMns <- VMns + 1;
		}
		
		else
		{
			VPls <- VPls + 1;
		}

		if (log) print(c((1 - q) * VPls, q * VMns))
	}

	cbind(VPls, VMns);
}


ShowDynamicsForq <- function(q, mu, sgm, rhoPls, rhoMns, nVotes)
{
	lmd <- SolveEqEq(mu, sgm)$par;

	cat("lmd =", lmd, "\n");
	cat("thtPls =", Tht(q, lmd), "\n");
	cat("thtMns =", ThtCnj(q, lmd), "\n");

	invisible(VModelForCoeff(q, lmd, rnorm(nVotes, mu, sgm), rhoPls, rhoMns, TRUE));
}


### Model of voting where coefficients are considered separately.
##################################################################

VModel <- function(votes, mu, sgm, lmd, rhoPlss, rhoMnss)
{
	qq <- rep(votes$q, votes$VPls + votes$VMns);
	pp <- rnorm(length(qq), mu, sgm);
	
	mdlVotes = data.frame();
	for (q in votes$q)
	{
		rhoPls <- rhoPlss[votes$q == q];
		rhoMns <- rhoMnss[votes$q == q];
		mdlVotes <- rbind(mdlVotes, cbind(q, VModelForCoeff(q, lmd, pp[qq == q], rhoPls, rhoMns)));
	}

	mdlVotes;
}

#####################################################################

lgs <- function(x, d, k) 
{
	1 / (1 + exp(-k * (x - d)));
}


logit <- function(x)
{
	log(x / (1 - x));
}


rhoCurve <- function(q, d, k)
{
	lgs(logit(q), d, k);
}
