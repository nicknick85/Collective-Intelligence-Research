### An example of the voting model. It should be called from "CI.RData" workspace.
#####################################################################################

ModelExample <- function()
{

### Soccer; UEFA Champions League; 23 July 2013; Hafnarfjordur vs. Ekranas; the draw outcome
#############################################################################################

data12_3 <- data12[data12$selection_index == 3,];


### Consider the history of voting (trading) up to the first moment where the total number of votes (dollars) > 15000.
#######################################################################################################################

data12_3_15000 <- data12_3[data12_3$ts <= "2013-07-23 21:12:49 MSK",]; 


### Get the state at the final moment of the history being considered.
#######################################################################

votes12_3 <- ToVotes(SumData(data12_3_15000));
votes12_3 <- votes12_3[(votes12_3$VPls != 0) | (votes12_3$VMns != 0), ];
votes12_3 <- votes12_3[order(votes12_3$q), ]


### Use some model parameters selected "by hands".
###################################################

mu <- 0.261;
sgm <- 0.003;
lmd <- SolveEqEq(mu, sgm)$par;
rhoPlss <- rhoCurve(votes12_3$q, -1.000, 21.897);
rhoMnss <- rhoCurve(votes12_3$q, -0.953, -113.112);


### The seed 2019 gives the result presented in the article. One may try other seeds.
######################################################################################

set.seed(2019);
modelRes12_3 <- VModel(votes12_3, mu, sgm, lmd, rhoPlss, rhoMnss);
print(cbind(votes12_3, modelRes12_3));

}
