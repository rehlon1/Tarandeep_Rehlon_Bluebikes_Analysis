# Technical Workflow

## Overview

The project deliberately separates responsibilities across SQL, Python and Tableau:

- **SQL**: combine, validate, clean and enrich journey-level data
- **Python**: prepare external weather enrichment and station-flow inputs
- **Tableau**: explore the prepared data and communicate decisions through interactive dashboards

This separation keeps data preparation reproducible and avoids rebuilding transformation logic inside the visualisation layer.

## 1. SQL preparation

Four annual journey tables for 2016-2019 are combined using `UNION ALL`.

`UNION ALL` was selected because each source row represents a journey and valid duplicate-looking values should not be removed by the union operation.

The main CTE pipeline is:

```text
combined_bluebikes_data
  - standardise selected columns
  - derive ride year and ride month
  - calculate journey duration

station_enriched_data
  - LEFT JOIN start station reference
  - LEFT JOIN end station reference
  - add station names, coordinates, districts and dock counts

cleaned_bluebikes_data
  - require end_time > start_time
  - exclude journeys > 24 hours
  - normalise birth-year text

final_bluebikes_data
  - validate rider age against journey year
  - keep journey rows while setting invalid birth years to NULL
```

Using `LEFT JOIN` for station enrichment ensures that valid journeys are retained even when historic station IDs are absent from the supplied station lookup.

## 2. Python weather enrichment

The weather notebook:

1. reads daily weather summary data
2. converts the weather date into a datetime field
3. maps NOAA stations to Bluebikes districts
4. reads the cleaned Bluebikes journey extract
5. derives journey start date
6. aggregates journeys to one row per **Date + start district**
7. merges the journey counts with district-day weather measures
8. validates duplicate keys, date coverage and null patterns
9. exports a Tableau-ready weather enrichment table

The merge is performed at the same analytical grain on both sides, avoiding a many-to-many join and avoiding repeated daily weather values across millions of journey records.

## 3. Python station-flow preparation

A second notebook aggregates:

- total journey starts by start station
- total journey ends by end station

These measures are outer-joined on station name to create the basis for station net-flow analysis.

## 4. Tableau

The Tableau layer uses the prepared datasets to build four dashboards:

1. Executive Overview
2. Demand & User Behaviour
3. Stations & Operations
4. Weather & Demand

The dashboards move from system-wide growth to behaviour, operational pressure and external conditions.

## Reusability

The staged design means additional years can be appended to the SQL combination stage, weather measures can be refreshed independently, and the Tableau layer can update without moving cleaning logic into the dashboards.
