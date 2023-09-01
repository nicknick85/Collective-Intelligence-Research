# Collective intelligence research
The repository contains data and scripts for the study _Interpretable Collective Intelligence of Non-rational Human Agents_ by Alexey V. Osipov and Nikolay N. Osipov ([arXiv:2204.13424](https://doi.org/10.48550/arXiv.2204.13424) \[cs.GT\]).
* _CI.RData_ is an _R_ workspace that contains some data preloaded from [our database](https://github.com/nicknick85/Prediction-Systems-Research/tree/master/Data) into tables _data12_ and _data13_ (we use _R x64 4.1.2_ for _Windows_). This workspace also contains all our scripts from the files described below.
## Data
In spite of the fact that our goal is the creation of a play-money prediction system for scientific research, we rely on [the detailed historical data](https://github.com/nicknick85/Prediction-Systems-Research/tree/master/Data) of the largest real-money prediction market. We believe that their great volume and level of detail are necessary for our studies.
* _Data/pmdata.backup_ is a backup of our database (we use _PostgreSQL x64 9.3_ for _Windows_).
* _Data/InCSV.7z_ contains the same database in CSV format.
* _Data/DataHandling.r_ contains scripts for uploading the data into _R_ and for further working with them. Before uploading the _PostgreSQL_ data, they must be restored from _Data/pmdata.backup_.
## Model
We implement and verify our ideas in _R_.
* _Model/MuSgmEstimation.r_ contains scripts for eliciting estimates of __&mu;__ and &sigma; from market states.
* _Model/GetGraph.r_ contains scripts for obtaining graphs of __&mu;__ and &sigma; estimates where "time" is aggregated _V_<sup>&nbsp;+</sup> and&nbsp;_V_<sup>&nbsp;-</sup>.
* _Model/VotingModel.r_ contains scripts for simulation of our model.
* _Model/ModelExample.r_ contains scripts for reproducing Table 3 from the article. This file should be loaded from _CI.RData_ workspace.
## Demonstration application
In order to see some of our analysis in real time via a shiny app, download all the files, open _CI.RData_ and use _source_ to read _app.R_.
