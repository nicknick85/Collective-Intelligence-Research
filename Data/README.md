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
Here we store general information about selections contained in our markets. Selections in a market are mutually exclusive outcomes and each market may be considered as a sample space. But each selection may be considered separately as a sample space &Omega;={0, 1}. The latter corresponds to our considerations in the article.
* e_id, market_id - the same as in __tickdata_markets__.
* selection_id - native identifiers of selections.
* selection_name - names of selections.
* selection_index - ordinal numbers of selections within corresponding markets.
* win_flag - 1 if a selection corresponds to a winner, 0 otherwise.
## tickdata_betstape
Here we store an initial state of each market (the state at the beginning of scanning) as well as all subsequent changes until the beginning of the corresponding event.
* e_id, market_id, selection_id - the same as in __tickdata_markets__ and __tickdata_selections__.
* ts - timestamps. For each market, the first timestamp is the time when scanning has been started. The data corresponding to it contains all the information about the initial state of the market. Subsequent timestamps corresponds to changes of the market state until the beginning of the corresponding event.
