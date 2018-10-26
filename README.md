# Prediction systems research
The repository contains data and scripts for studies described in the article ...
* File _PSys.RData_ is an _R_ workspace that contains some data preloaded from [our database](https://github.com/nicknick85/Prediction-Systems-Research/tree/master/Data) into tables _data12_ and _data13_. This workspace also contains all our scripts from the files described below.
## Data
In spite of the fact that our goal is the creation of a play-money prediction system for medical research, we rely on [detailed historical data](https://github.com/nicknick85/Prediction-Systems-Research/tree/master/Data) of the largest real-money prediction market. We believe that their great volume and level of detail are necessary for our studies.
* File _Data/pmdata.backup_ is a backup of our database (we use _PostgreSQL_ ...).
* File _Data/DataHandling.r_ contains scripts for uploading the _PostgreSQL_ data into _R_ and for further working with them. Before uploading, the data must be restored from _Data/pmdata.backup_.
* Folder _Data/InCSV_ contains the database in CSV format.
## Model
...
* File _Model/MuSgmEstimation.r_ contains scripts for eliciting estimates of __&mu;__ and &sigma; from market data.
* File _Model/GetGraph.r_ contains scripts for obtaining graphs of __&mu;__ and &sigma; estimates with the aggregated _V_<sup> +</sup> and&nbsp;_V_<sup> -</sup> in the role of "time".
* File _Model/VotingModel.r_ contains scripts for simulation of our model.
* File _Model/ModelExample.r_ contains scripts for reproducing Table ... from the article. This file should be loaded from _PSys.RData_ workspace.
