# Data

Raw project data is not stored in this public repository.

The analysis used:

- Bluebikes journey data for 2016, 2017, 2018 and 2019
- a station reference table
- NOAA/NCEI GHCN-Daily weather data
- a mapping between selected weather stations and districts

The cleaned journey extract contains **6,834,930 rows**, and the packaged Tableau workbook includes large extract files. Keeping those files outside the repository makes the portfolio focused on the analytical logic rather than distributing large training datasets.

Expected filenames referenced by the original Python notebooks include:

```text
Final BlueBikes Data.csv
Weather_Summary_2016-2019.csv
NOAA_Station_mapping.csv
```

Generated outputs include:

```text
Weather Enrichment Data.csv
Station Start_End Data.csv
```
