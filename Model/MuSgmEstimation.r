## Scripts for estimating mu and sigma. 
## Authors: A.V.Osipov & N.N.Osipov
########################################


Tht <- function(q, lmd)
{
	(exp(-lmd * q) - 1) / (exp(-lmd) - 1);   
}


ThtCnj <- function(q, lmd)
{
	(exp(lmd * q) - 1) / (exp(lmd) - 1);    ### 1 - Tht(1 - q, lmd);	
}


LogL <- function(mu_sgm, votes, lmd)
{
	q <- votes$q;
	ThtPls <- Tht(q, lmd);
	ThtMns <- ThtCnj(q, lmd);
	VPls <- votes$VPls;
	VMns <- votes$VMns;
	
	mu <- mu_sgm[1];
	sgm <- mu_sgm[2];
	
	sum(VPls[VPls > 0] * pnorm(ThtPls[VPls > 0], mu, sgm, lower.tail=FALSE, log.p = TRUE)) + sum(VMns[VMns > 0] * pnorm(ThtMns[VMns > 0], mu, sgm, log.p = TRUE));
}


OptimLogL <- function(votes, lmd)
{
  optim(c(0.5, 0.01), LogL, votes = votes, lmd = lmd, control = list(fnscale = -1));
}


### Equilibrium equation for risk seeking experts.
###################################################

EqEq <- function(lmd, mu, sgm)
{
	abs(log(1 - mu) + pnorm(ThtCnj(mu, lmd), mu, sgm, lower.tail = FALSE, log.p = TRUE) - log(mu) -  pnorm(Tht(mu, lmd), mu, sgm, log.p = TRUE));
}


SolveEqEq <- function(mu, sgm)
{
	optim(-0.05, EqEq, mu = mu, sgm = sgm, control = list(warn.1d.NelderMead = FALSE));
}


OuterEq <- function(lmd, votes)
{
	mu_sgm <- OptimLogL(votes, lmd)$par;
	abs(lmd - SolveEqEq(mu_sgm[1], mu_sgm[2])$par);
}


EstimateMuSgm <- function(votes, iniLmd = -0.1)
{	
	oeRes <- optim(iniLmd, OuterEq, votes = votes, control = list(warn.1d.NelderMead = FALSE));		
	llRes <- OptimLogL(votes, oeRes$par);
	
	data.frame(
		mu = llRes$par[1],
		sgm = llRes$par[2],
		lmd = oeRes$par,
		outerEqVal = oeRes$value,
		lhood = llRes$value);
}