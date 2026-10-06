# Data Quality & Validation

Data quality checks were performed throughout the workflow so that changes in row counts and analytical coverage could be explained.

## Source combination

The four annual journey tables were reconciled after the `UNION ALL` step to confirm that all source records were represented before cleaning.

## Journey-time validation

Two duration rules were applied:

- `end_time` must be later than `start_time`
- journey duration must be no more than 24 hours

**Rows removed: 5,390**

- 10 records had invalid time order
- 5,380 journeys exceeded 24 hours

These records were excluded because they would distort duration-based analysis.

## Duplicate validation

The final cleaned data was checked for duplicate journey keys.

**Result: 0 duplicate journey keys.**

## Birth-year cleaning

The source birth-year field included:

- SQL nulls
- `\\N`
- numeric values stored with `.0`
- values that implied implausible rider ages

The SQL pipeline first normalises the field using `NULLIF` and `REPLACE`, then validates the implied age against the year of the journey.

A valid rider age was treated as **16 to 100**.

Invalid or missing birth years were set to `NULL`; the journey itself was retained.

After cleaning, **448,150 records** remained without a usable birth year. These were not imputed because there was no reliable basis for estimating them.

## Station-reference coverage

The historic station lookup does not contain every station ID found in the journey data.

Approximately **1.9% of journeys** do not have a mapped start district, with a similar issue for end districts.

The project deliberately retains these journeys for:

- system-wide totals
- temporal analysis
- user-type analysis

They are excluded only from analyses that specifically require mapped district or station attributes.

## Weather matching

Weather enrichment is performed at **Date + District** grain.

The final weather-ready output represents **6,703,545 journeys** with a valid mapped start district.

Validation includes:

- duplicate Date + District keys
- row-count comparisons before and after merge
- null-value checks
- date-range checks
- maximum temperature lower than minimum temperature checks

## Final analytical dataset

The final SQL dataset contains **6,834,930 cleaned journeys** and powers the system-wide Tableau analysis.
