# Detailed historical data from Bеtfаir
Here we describe the tables from the database contained in _pmdata.backup_ (a _PostgreSQL_ backup file). The best way to handle them is to use the functions _GetData_ or _GetDataFromCSV_ from the file _DataHandling.r_.
## tickdata_markets
Here we store general information about 24 football events and corresponding markets. Four markets are considered for each event (see below).
* _e_id_ - identifiers of football events. This column has been filled by the loader and contains the numbers from 1 to 24.
* _e_name_ - full names of events.
* _market_id_ - native identifiers of markets.
* _market_name_ - names of markets.
* _market_index_ - 1 for "match odds", 2 for "over/under 2.5 goals", 3 for "correct score", and 4 for "over/under 1.5 goals".
## tickdata_selections
Here we store general information about selections contained in our markets. Selections in a market are mutually exclusive outcomes and each market may be considered as a sample space. But each selection may be considered separately as a sample space &Omega;={0, 1}. The latter corresponds to our considerations in the article.
* _e_id_, _market_id_ - the same as in __tickdata_markets__.
* _selection_id_ - native identifiers of selections.
* _selection_name_ - names of selections.
* _selection_index_ - ordinal numbers of selections within corresponding markets.
* _win_flag_ - 1 if a selection corresponds to a winner, 0 otherwise.
## tickdata_betstape
Here we store an initial state of each market (the state at the beginning of scanning) as well as all subsequent changes until the beginning of the corresponding event.
* _e_id_, _market_id_, _selection_id_ - the same as in __tickdata_markets__ and __tickdata_selections__.
* _ts_ - timestamps. For each market, the first timestamp is the time when scanning has been started. The data corresponding to it contains all the information about the initial state of the market. Subsequent timestamps corresponds to changes of the market state until the beginning of the corresponding event.
* _k_ - a coefficient for which a certain operation has been performed at the time _ts_. If _ts_ is the first timestamp for the market, then _k_ that correspond to it are the initial coefficients (the coefficients at the beginning of scanning). We have _q_ = 1/_k_ (see the article).
* _back_ - a back bet placed on the coefficient _k_ at the time _ts_. It may be negative if money has been withdrawn. For the initial state, it is the sum of back bets that have been placed on the coefficient _k_ before the beginning of scanning. Concerning the article notation, we have _V_<sup> +</sup> = &sum; _back_ and _S_<sup> +</sup> = &sum; _k_ _back_.
* _lay_ - a lay bet placed on the coefficient _k_ at the time _ts_. It may be negative if money has been withdrawn. For the initial state, it is the sum of lay bets that have been placed on the coefficient _k_ before the beginning of scanning. Concerning the article notation, we have _V_<sup> -</sup> = &sum; (_k_ - 1) _lay_ and _S_<sup> -</sup> = &sum; _k_ _lay_.
* _matched_ - money matched at the moment _ts_. Note that this column does not contain any new information beyond that which can be retrieved from the others. One may exploit the condition "_matched_ is null" to obtain the initial state of the market.
