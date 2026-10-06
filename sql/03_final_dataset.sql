-- =========================================================================================
-- FINAL DATA SCRIPT
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
	bike_id, start_time, end_time, start_station_id, end_station_id, user_type,
	final_user_birth_year As user_birth_year, ride_year, ride_month, journey_time,
	start_jrny_name, start_jrny_latitude, start_jrny_longitude, start_jrny_district, start_jrny_docks,
	end_jrny_name, end_jrny_latitude, end_jrny_longitude, end_jrny_district, end_jrny_docks
From final_bluebikes_data;

