-- =========================================================================================
-- 1. INITIAL DATA EXPLORATION
-- Review sample records from each yearly dataset and inspect the stations table
-- =========================================================================================

Select * From bluebikes_2016
Limit 100;

Select * From bluebikes_2017
Limit 100;

Select * From bluebikes_2018
Limit 100;

Select * From bluebikes_2019
Limit 100;

Select * From bluebikes_stations;


-- =========================================================================================
-- 2. COMBINE 2016–2019 DATA
-- CTE used to combine all yearly datasets and add ride year and month for trend analysis
-- =========================================================================================

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 	
	FROM bluebikes_2019)

Select * From combined_bluebikes_data
Limit 100;


-- =========================================================================================
-- 3. VALIDATE UNION ALL ROW COUNT
-- Confirm all records from the four yearly datasets are present in the combined dataset
-- Expected result: 0
-- =========================================================================================

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 	
	FROM bluebikes_2019)
	
Select
SUM((Select Count (*) from bluebikes_2016)
+
(Select Count (*) from bluebikes_2017)
+
(Select Count (*) from bluebikes_2018)
+
(Select Count (*) from bluebikes_2019)
-
(Select Count (*) from combined_bluebikes_data));

-- Result: 0
-- All expected records from 2016–2019 have been successfully included in the combined dataset


-- =========================================================================================
-- 4. CHECK FOR NULL VALUES
-- Check all main journey fields for genuine SQL NULL values
-- =========================================================================================

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 	
	FROM bluebikes_2019)

Select
    Count(*) Filter (Where bike_id IS NULL) AS null_bike_id,
    Count(*) Filter (Where start_time IS NULL) AS null_start_time,
    Count(*) Filter (Where end_time IS NULL) AS null_end_time,
    Count(*) Filter (Where start_station_id IS NULL) AS null_start_station,
    Count(*) Filter (Where end_station_id IS NULL) AS null_end_station,
    Count(*) Filter (Where user_type IS NULL) AS null_user_type,
    Count(*) Filter (Where user_birth_year IS NULL) AS null_birth_year,
    Count(*) Filter (Where user_gender IS NULL) AS null_gender
From combined_bluebikes_data;

-- Result: 9,592 genuine NULL values identified in user_birth_year


-- =========================================================================================
-- 5. INVESTIGATE USER BIRTH YEAR
-- Review birth-year values for missing data, inconsistent formatting and unrealistic values
-- =========================================================================================

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 	
	FROM bluebikes_2019)

Select
    user_birth_year,
    Count(*) AS number_of_entries
From combined_bluebikes_data
Group By user_birth_year
Order By user_birth_year DESC;

-- Findings:
-- 9,592 genuine NULL values identified
-- 437,557 '\N' values identified and treated as missing data
-- Some birth years are duplicated because of inconsistent decimal formatting
-- Birth years range from 1863 to 2003
-- These issues will be standardised during the cleaning stage


-- =========================================================================================
-- 6. VALIDATE MINIMUM USER AGE
-- Bluebikes has a minimum rider age of 16
-- Check the youngest recorded birth years against the year in which the journey occurred
-- =========================================================================================

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 	
	FROM bluebikes_2019)

Select
    user_birth_year,
    ride_year,
    Count(*) AS number_of_rides
From combined_bluebikes_data
Where user_birth_year IN ('2000', '2001', '2002', '2003')
Group By user_birth_year, ride_year
Order By user_birth_year, ride_year;

-- Result: The youngest recorded birth years correspond with ride years in which users would meet
-- the minimum age requirement of 16. No issues identified


-- =========================================================================================
-- 7. VALIDATE USER TYPE
-- Review the categories stored within user_type and check for unexpected values
-- =========================================================================================

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 	
	FROM bluebikes_2019)

Select
    user_type,
    Count(*) AS number_of_entries
From combined_bluebikes_data
Group By user_type
Order By user_type DESC;

-- Result: Only Subscriber and Customer values are present
-- No anomalies identified within user_type


-- =========================================================================================
-- 8. VALIDATE USER GENDER
-- Review the categories stored within user_gender
-- =========================================================================================

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 	
	FROM bluebikes_2019)

Select
    user_gender,
    Count(*) AS number_of_entries
From combined_bluebikes_data
Group By user_gender
Order By user_gender DESC;

-- Result: Gender is coded as 0, 1 and 2
-- The supplied data does not define what each code represents, therefore gender will not
-- be used in the analysis unless the coding can be reliably verified


-- =========================================================================================
-- 9. VALIDATE START STATION IDs
-- Check whether journey start_station_id values can be matched to the supplied stations table
-- =========================================================================================

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 	
	FROM bluebikes_2019)

Select
    Count(*) As unmatched_start_station_rows
From combined_bluebikes_data
Left Join bluebikes_stations
    On combined_bluebikes_data.start_station_id = bluebikes_stations.id
Where bluebikes_stations.id Is Null;

-- Result: 131,570 journeys contain a start station ID that cannot be matched to the supplied stations table


-- 9.1 Investigate unmatched start station IDs by year

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 	
	FROM bluebikes_2019)

Select
    combined_bluebikes_data.start_station_id,
    combined_bluebikes_data.ride_year,
    Count(*) As number_of_journeys
From combined_bluebikes_data
Left Join bluebikes_stations
    On combined_bluebikes_data.start_station_id = bluebikes_stations.id
Where bluebikes_stations.id Is Null
Group By combined_bluebikes_data.start_station_id, combined_bluebikes_data.ride_year
Order By combined_bluebikes_data.start_station_id, combined_bluebikes_data.ride_year;


-- =========================================================================================
-- 10. VALIDATE END STATION IDs
-- Check whether journey end_station_id values can be matched to the supplied stations table
-- =========================================================================================

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 	
	FROM bluebikes_2019)

Select
    Count(*) As unmatched_end_station_rows
From combined_bluebikes_data
Left Join bluebikes_stations
    On combined_bluebikes_data.end_station_id = bluebikes_stations.id
Where bluebikes_stations.id Is Null;

-- Result: 130,524 journeys contain an end station ID that cannot be matched to the supplied stations table


-- 10.1 Investigate unmatched end station IDs by year

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 	
	FROM bluebikes_2019)

Select
    combined_bluebikes_data.end_station_id,
    combined_bluebikes_data.ride_year,
    Count(*) As number_of_journeys
From combined_bluebikes_data
Left Join bluebikes_stations
    On combined_bluebikes_data.end_station_id = bluebikes_stations.id
Where bluebikes_stations.id Is Null
Group By combined_bluebikes_data.end_station_id, combined_bluebikes_data.ride_year
Order By combined_bluebikes_data.end_station_id, combined_bluebikes_data.ride_year;

-- Finding: Some historical station IDs are not present in the supplied stations table
-- The pattern is consistent across both start and end station IDs, suggesting that the supplied
-- stations table does not contain a complete historical record of the Bluebikes network
-- Decision: Retain the affected journeys, although they may not be fully enriched with station metadata


-- =========================================================================================
-- 11. VALIDATE JOURNEY START AND END TIMES
-- Check for journeys where the end time is equal to or earlier than the start time
-- =========================================================================================

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 	
	FROM bluebikes_2019)

Select Count(*) From combined_bluebikes_data
WHERE end_time <= start_time;

-- Result: 10 journeys have an end time earlier than the start time
-- Decision: Remove these records during the cleaning stage because they represent invalid journeys


-- =========================================================================================
-- 12. CHECK FOR DUPLICATE JOURNEYS
-- No consistent unique journey ID exists across all four datasets
-- A journey is therefore checked using bike ID, timestamps and start/end station IDs
-- =========================================================================================

WITH combined_bluebikes_data AS(
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2016 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2016
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2017 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2017
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2018 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 
	FROM bluebikes_2018
UNION ALL
SELECT bike_id, start_time, end_time, start_station_id, end_station_id, user_type, user_birth_year, user_gender,
	2019 AS ride_year, EXTRACT(MONTH FROM start_time) as ride_month 	
	FROM bluebikes_2019)

Select Count(*)
From 
(Select bike_id, start_time, end_time, start_station_id, end_station_id
From combined_bluebikes_data
Group By bike_id, start_time, end_time, start_station_id, end_station_id
Having Count(*) > 1) As duplicate_journeys;

-- Result: 0 duplicate journeys identified


-- =========================================================================================
-- 13. CREATE AND REVIEW JOURNEY TIME
-- Calculate journey duration in minutes and round to two decimal places
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
	FROM bluebikes_2019)

Select * From combined_bluebikes_data
Order By journey_time Desc
Limit 5000;

-- Finding: A number of journeys have recorded durations exceeding 24 hours


-- =========================================================================================
-- 14. VALIDATE JOURNEYS OVER 24 HOURS
-- Count journeys exceeding the 1,440-minute threshold
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
	FROM bluebikes_2019)

Select Count (*)
	From combined_bluebikes_data
	Where journey_time > 1440;

-- Result: 5,380 journeys exceed 24 hours
-- Bluebikes considers a bike missing if it is not returned within 24 hours
-- Decision: Journeys exceeding 24 hours will be removed during cleaning because they are anomalous
-- and could distort journey-duration analysis


-- =========================================================================================
-- 15. ENRICH JOURNEY DATA WITH STATION INFORMATION
-- Add station name, coordinates, district and dock capacity for both start and end stations
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
	ON combined_bluebikes_data.end_station_id = end_station.id)

Select * From station_enriched_data
Limit 10;