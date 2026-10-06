# Python Analysis

The original project notebooks are included in this folder.

## weather_enrichment.ipynb

Purpose: prepare weather measures at the same grain as the operational demand analysis.

Main steps:

1. load daily weather summary data
2. convert `DATE` to datetime
3. map NOAA weather stations to districts
4. load the cleaned Bluebikes journey extract
5. derive journey start date
6. aggregate starts by `DATE + start_jrny_district`
7. merge rainfall, snowfall, snow depth and temperature measures
8. validate duplicates, coverage and nulls
9. export `Weather Enrichment Data.csv`

Key pandas operations include `read_csv`, `to_datetime`, `merge`, `groupby`, `reset_index`, `rename`, duplicate checks and null checks.

## station_flow_analysis.ipynb

Purpose: prepare station-level journey starts and ends for directional-flow analysis.

Main steps:

1. aggregate total starts by start station
2. aggregate total ends by end station
3. rename both station keys consistently
4. outer-join the two summaries
5. export `Station Start_End Data.csv`

The output supports the Tableau net-flow analysis used to identify likely accumulation and depletion pressure.

## Required inputs

The notebooks reference local project files that are not included in this repository:

```text
Final BlueBikes Data.csv
Weather_Summary_2016-2019.csv
NOAA_Station_mapping.csv
```

See [../data/README.md](../data/README.md) for more information.
