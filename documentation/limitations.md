# Assumptions & Limitations

## Historic station coverage

The station reference is not a complete historic record. Unmatched station IDs are retained in the journey dataset, but district and other station attributes are unavailable for those records.

## Starts per dock

Starts per dock is a **relative demand-to-capacity indicator**:

```text
journey starts / stated dock count
```

It is not a measure of live occupancy, dock availability or true utilisation.

## Weather representation

Weather is represented at **district-day level** using selected observation stations. It does not represent conditions at every individual bikeshare station or at each journey's exact start time.

## Snowfall coverage

Snowfall reporting is less complete than rainfall and temperature coverage. Snowfall comparisons are therefore supporting evidence rather than the strongest weather measure.

## Association vs causation

The project identifies associations between weather and demand. Temperature overlaps strongly with seasonality, so the analysis does not claim that weather alone causes demand changes.

## User intent

Trip purpose is not recorded. Terms such as **commuter-style** and **leisure-style** describe timing patterns and are not confirmed trip purposes.

## Birth year

Missing and invalid birth-year values were not imputed. Age-based analysis was therefore not used as a primary decision-making measure.

## Gender coding

The gender field contained codes 0, 1 and 2, but the supplied data did not provide a sufficiently clear definition of the categories. The project therefore avoids using gender as a primary dimension in stakeholder recommendations.
