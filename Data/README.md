# Tick data loaded from Bеtfаir
...
## tickdata_markets
Here we store general information about 24 football events and corresponding markets. Four markets are considered for each event (see below).
* e_id - identifiers of football events. This column has been filled by the loader and contains the numbers from 1 to 24.
* e_name - full names of events.
* market_id - native identifiers of markets.
* market_name - names of markets.
* market_index - 1 for "match odds", 2 for "over/under 2.5 goals", 3 for "correct score", and 4 for "over/under 1.5 goals".
## tickdata_selections
