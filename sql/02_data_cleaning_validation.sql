-- =========================================================================================
-- 1. CREATE FINAL CLEANED BLUEBIKES DATASET
-- Combine yearly journey data, enrich with station information and apply agreed cleaning rules
-- =========================================================================================

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month,
	ROUND(EXTRACT(Epoch From (end_time - start_time)) / 60, 2) As journey_time
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month,
	Round(EXTRACT(Epoch From (end_time - start_time)) / 60, 2) As journey_time
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month,
	Round(EXTRACT(Epoch From (end_time - start_time)) / 60, 2) As journey_time
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month,
	Round(EXTRACT(Epoch From (end_time - start_time)) / 60, 2) As journey_time
	FROM bluebikes_2019),

-- Enrich journey records with start and end station information
-- Left Joins are used so journeys with historical station IDs missing from the supplied
-- stations table are retained in the dataset

station_enriched_data AS (
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	ride_year, ride_month, journey_time,
	start_station.name As start_jrny_name,
	start_station.latitude As start_jrny_latitude,
	start_station.longtitude As start_jrny_longitude,
	start_station.district As start_jrny_district,
	start_station.total_docks As start_jrny_docks,
	end_station.name As end_jrny_name,
	end_station.latitude As end_jrny_latitude,
	end_station.longtitude As end_jrny_longitude,
	end_station.district As end_jrny_district,
	end_station.total_docks As end_jrny_docks
	FROM combined_bluebikes_data
LEFT JOIN bluebikes_stations AS start_station
	ON combined_bluebikes_data.start_station_id = start_station.id
LEFT JOIN bluebikes_stations AS end_station
	ON combined_bluebikes_data.end_station_id = end_station.id),

-- Apply journey cleaning rules and standardise the birth-year field
-- Invalid journeys are excluded and '\N' values are converted to NULL
-- Decimal formatting is removed from birth-year values

cleaned_bluebikes_data AS (
Select *,
Nullif(REPLACE(user_birth_year, '.0', ''), '\N') AS cleaned_user_birth_year
From station_enriched_data
Where end_time > start_time
AND journey_time <= 1440),

-- Validate birth years using the rider's age at the time of the journey
-- Valid ages are treated as 16-100 years
-- Invalid or missing birth years are converted to NULL while the journey itself is retained

final_bluebikes_data AS (
Select *,
Case
When cleaned_user_birth_year Is Null Then Null
When Cast(cleaned_user_birth_year As Integer) 
Between (ride_year - 100) And (ride_year - 16)
Then Cast(cleaned_user_birth_year As Integer)
Else Null
End As final_user_birth_year
From cleaned_bluebikes_data)


-- =========================================================================================
-- 2. VALIDATE FINAL ROW COUNT
-- Compare the original number of journey records with the cleaned dataset
-- Expected result: 5,390 rows removed
-- =========================================================================================

Select
	(Select Count(*) From bluebikes_2016)
	+
	(Select Count(*) From bluebikes_2017)
	+
	(Select Count(*) From bluebikes_2018)
	+
	(Select Count(*) From bluebikes_2019)
	-
	(Select Count(*) From final_bluebikes_data) As rows_removed;

-- Result: 5,390 rows removed
-- 10 journeys were removed because the end time was not later than the start time
-- 5,380 journeys were removed because the recorded journey duration exceeded 24 hours
-- Birth-year cleaning did not remove journey records; invalid birth years were instead converted to NULL


-- =========================================================================================
-- 3. VALIDATE FINAL BIRTH-YEAR CLEANING
-- Review the final birth-year values after formatting, missing-value and age validation
-- =========================================================================================

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month,
	ROUND(EXTRACT(Epoch From (end_time - start_time)) / 60, 2) As journey_time
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month,
	Round(EXTRACT(Epoch From (end_time - start_time)) / 60, 2) As journey_time
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month,
	Round(EXTRACT(Epoch From (end_time - start_time)) / 60, 2) As journey_time
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month,
	Round(EXTRACT(Epoch From (end_time - start_time)) / 60, 2) As journey_time
	FROM bluebikes_2019),

station_enriched_data AS (
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	ride_year, ride_month, journey_time,
	start_station.name As start_jrny_name,
	start_station.latitude As start_jrny_latitude,
	start_station.longtitude As start_jrny_longitude,
	start_station.district As start_jrny_district,
	start_station.total_docks As start_jrny_docks,
	end_station.name As end_jrny_name,
	end_station.latitude As end_jrny_latitude,
	end_station.longtitude As end_jrny_longitude,
	end_station.district As end_jrny_district,
	end_station.total_docks As end_jrny_docks
	FROM combined_bluebikes_data
LEFT JOIN bluebikes_stations AS start_station
	ON combined_bluebikes_data.start_station_id = start_station.id
LEFT JOIN bluebikes_stations AS end_station
	ON combined_bluebikes_data.end_station_id = end_station.id),

cleaned_bluebikes_data AS (
Select *,
Nullif(REPLACE(user_birth_year, '.0', ''), '\N') AS cleaned_user_birth_year
From station_enriched_data
Where end_time > start_time
AND journey_time <= 1440),

final_bluebikes_data AS (
Select *,
Case
When cleaned_user_birth_year Is Null Then Null
When Cast(cleaned_user_birth_year As Integer) 
Between (ride_year - 100) And (ride_year - 16)
Then Cast(cleaned_user_birth_year As Integer)
Else Null
End As final_user_birth_year
From cleaned_bluebikes_data)

Select
    final_user_birth_year,
    Count(*) AS number_of_entries
From final_bluebikes_data
Group By final_user_birth_year
Order By final_user_birth_year DESC;

-- Validation confirms that:
-- '\N' values are no longer present and are represented as NULL
-- Birth years with decimal formatting have been standardised
-- Valid birth years are stored as integers
-- Birth years resulting in an age below 16 or above 100 are represented as NULL
-- Journey records with missing or invalid birth years have been retained