# Tableau Calculated Fields

The packaged Tableau workbook contains calculated fields supporting the four-dashboard analysis.

## Journey Growth 2016-2019

```tableau
(
    SUM(IF [ride_year] = 2019 THEN 1 ELSE 0 END)
    /
    SUM(IF [ride_year] = 2016 THEN 1 ELSE 0 END)
) - 1
```

## Subscriber Share

```tableau
SUM(
    IF [user_type] = "Subscriber"
    THEN 1
    ELSE 0
    END
) / COUNT([bike_id])
```

## Journey Starts per Dock

```tableau
COUNT([bike_id]) / AVG([start_jrny_docks])
```

## Day Split

```tableau
IF DATENAME('weekday', [start_time]) = 'Saturday'
OR DATENAME('weekday', [start_time]) = 'Sunday'
THEN 'Weekend'
ELSE 'Weekday'
END
```

## Average Daily Journeys

```tableau
COUNT([bike_id]) / COUNTD(DATETRUNC('day', [start_time]))
```

## Rainfall Level

```tableau
IF [Rainfall (mm)] = 0 THEN "Dry"
ELSEIF [Rainfall (mm)] <= 2.5 THEN "Light Rain"
ELSEIF [Rainfall (mm)] <= 10 THEN "Moderate Rain"
ELSE "Heavy Rain"
END
```

## Snowfall Day

```tableau
IF ISNULL([Snowfall (mm)]) THEN "No Data"
ELSEIF [Snowfall (mm)] = 0 THEN "No Snowfall"
ELSE "Snowfall"
END
```

## Average Temperature

```tableau
([Max Temp (°C)] + [Min Temp (°C)]) / 2
```

## Absolute Net Flow

```tableau
ABS([Net Flow])
```

These fields support KPI reporting, user segmentation, relative station-pressure analysis and weather categorisation.
