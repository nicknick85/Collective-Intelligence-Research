# Prediction systems research
The repository contains data and scripts for studies described in the article ...
## Data
In spite of the fact that our goal is the creation of a play-money prediction system for medical research, we rely on [detailed historical data](https://github.com/nicknick85/Prediction-Systems-Research/tree/master/Data) of the largest real-money prediction market. We believe that their great volume and level of detail are necessary for our studies.
* File _Data/pmdata.backup_ is a backup of our database (we use _PostgreSQL_ ...).
* File _Data/DataHandling.r_ contains scripts for uploading the _PostgreSQL_ data into _R_ and for further working with them. Before uploading, the data must be restored from _Data/pmdata.backup_.
* Folder _Data/InCSV_ contains the database in CSV format.
## Model
...
