USE [road];

SELECT * FROM road_acc;

-- CY_Casualties (Current Year Casualties)
SELECT YEAR(accident_date), COUNT(*)
FROM road_acc
GROUP BY YEAR(accident_date);

SELECT SUM(number_of_casualties) 'Total Casualties'
FROM road_acc
WHERE YEAR(accident_date) = 2022;


WITH CY_accident AS (
	SELECT SUM(number_of_casualties) 'Current Year - Casualties - 2022'
	FROM road_acc
	WHERE YEAR(accident_date) = 2022
),
	PY_accident AS (
	SELECT SUM(number_of_casualties)  'Previous Year - Casualties -2021'
	FROM road_acc
	WHERE YEAR(accident_date) = 2021
)
SELECT * FROM CY_accident, PY_accident;

-- 2. CY – Fatal Casualties - 2022

WITH Fatal_acc AS (
	SELECT SUM(number_of_casualties) 'Fatal_casualties'
	FROM road_acc
	WHERE (accident_severity = 'Fatal' AND	YEAR(accident_date) = 2022)
),
 serious_acc AS (
	SELECT SUM(number_of_casualties) 'Serious_casualties'
	FROM road_acc
	WHERE (accident_severity = 'Serious' AND	YEAR(accident_date) = 2022)
),
Slight_acc AS (
	SELECT SUM(number_of_casualties) 'Slight_casualties'
	FROM road_acc
	WHERE (accident_severity = 'Slight' AND	YEAR(accident_date) = 2022)
)
SELECT * FROM Fatal_acc, serious_acc, Slight_acc;

	
-- Total Number of [Slight, Fatal, Serious] Casualties

WITH Fatal_acc AS (
	SELECT SUM(number_of_casualties) 'Fatal_casualties'
	FROM road_acc
	WHERE (accident_severity = 'Fatal')
),
 serious_acc AS (
	SELECT SUM(number_of_casualties) 'Serious_casualties'
	FROM road_acc
	WHERE (accident_severity = 'Serious')
),
Slight_acc AS (
	SELECT SUM(number_of_casualties) 'Slight_casualties'
	FROM road_acc
	WHERE (accident_severity = 'Slight' )
)
SELECT * FROM Fatal_acc, serious_acc, Slight_acc;

-- Percentage(%) of Accidents that got Severity – Slight

	SELECT CAST(SUM(number_of_casualties) AS DECIMAL (10,2)) * 100/
	(SELECT (CAST(SUM(number_of_casualties) AS DECIMAL (10,2)))
	FROM road_acc) AS 'Slight_casualties - %'
	FROM road_acc
	WHERE accident_severity = 'Slight';
	
	SELECT 
		CAST(SUM(CASE
				WHEN accident_severity = 'Slight' THEN number_of_casualties  ELSE 0 END) * 100.0
				/ NULLIF(SUM(number_of_casualties),0) AS DECIMAL(10,2))
				AS [Slight %]
				FROM road_acc;


WITH Slight_Percentage AS (
	SELECT 
	CAST(SUM(CASE
		WHEN accident_severity = 'Slight' THEN number_of_casualties ELSE 0 END) * 100.0 
		/ NULLIF(SUM(number_of_casualties), 0 )AS DECIMAL(10,2))
		AS [Slight %]
		FROM road_acc
),
  Serious_Percentage AS (
	SELECT
	CAST(SUM(CASE
		WHEN accident_severity = 'Serious' THEN number_of_casualties ELSE 0 END) * 100.0
		/ NULLIF(SUM(number_of_casualties), 0) AS DECIMAL(10,2))
		AS [Serious %]
		FROM road_acc
),
  Fatal_Percentage AS (
	SELECT 
	CAST(SUM(CASE
			WHEN accident_severity = 'Fatal' THEN number_of_casualties ELSE 0 END) * 100.0
			/ NULLIF(SUM(number_of_casualties), 0) AS DECIMAL(10,2))
			AS [Fatal%]
			FROM road_acc
)
	SELECT * FROM Fatal_Percentage,Serious_Percentage,Slight_Percentage;



	-- Vehicle Group – Total Number of Casualties


SELECT 
	CASE
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
		WHEN vehicle_type IN ('Car','Taxi/Private hire car') THEN 'Cars'
		WHEN vehicle_type IN ('Motorcycle 125cc and under',
							  'Motorcycle 50cc and under',
							  'Motorcycle over 125cc and up to 500cc',
							  'Motorcycle over 500cc') THEN 'Bikes'
		WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)',
							  'Minibus (8 - 16 passenger seats)') THEN 'Buses'
		WHEN vehicle_type IN ('Van / Goods 3.5 tonnes mgw or under',
							  'Goods over 3.5t. and under 7.5t',
							  'Goods 7.5 tonnes mgw and over') THEN 'Van'
		ELSE 'Other Vehicle'
		END AS [Vehicle Group],
		SUM(number_of_casualties) [Total Number Of Casualties]
	FROM road_acc
	GROUP BY
	CASE
		WHEN vehicle_type IN ('Agricultural vehicle') THEN 'Agricultural'
		WHEN vehicle_type IN ('Car','Taxi/Private hire car') THEN 'Cars'
		WHEN vehicle_type IN ('Motorcycle 125cc and under',
							  'Motorcycle 50cc and under',
							  'Motorcycle over 125cc and up to 500cc',
							  'Motorcycle over 500cc') THEN 'Bikes'
		WHEN vehicle_type IN ('Bus or coach (17 or more pass seats)',
							  'Minibus (8 - 16 passenger seats)') THEN 'Buses'
		WHEN vehicle_type IN ('Van / Goods 3.5 tonnes mgw or under',
							  'Goods over 3.5t. and under 7.5t',
							  'Goods 7.5 tonnes mgw and over') THEN 'Van'
		ELSE 'Other Vehicle'
		END
	ORDER BY SUM(number_of_casualties) DESC;


	-- CY – Casualties Monthly Trend


		SELECT DATENAME(MONTH,accident_date) [Month Name],
			SUM(number_of_casualties) [Total casualties]
		FROM road_acc
		WHERE YEAR(accident_date) = 2022
		GROUP BY DATENAME(MONTH,accident_date) 
		ORDER BY [Total Casualties] DESC;
	
	-- Previous Year Casualties Monthly Trend

		SELECT DATENAME(MONTH, accident_date) [Month Name],
		SUM(number_of_casualties) [Total Casualties]
		FROM road_acc
		WHERE YEAR(accident_date) = 2021
		GROUP BY DATENAME(MONTH, accident_date)
		ORDER BY [Total Casualties] DESC;


		-- Types of Road – Total Number of Casualties:

		SELECT road_type,
				SUM(number_of_casualties) [Total Casualties]
		FROM road_acc
		WHERE YEAR(accident_date) = 2022
		GROUP BY road_type
		ORDER BY SUM(number_of_casualties) DESC;


  -- Area – wise Percentage(%) and Total Number of Casualties

SELECT 
  urban_or_rural_area,
  SUM(number_of_casualties) AS total_casualties,
  CAST(ROUND(SUM(number_of_casualties) * 100.0 / 
        (SELECT SUM(number_of_casualties) FROM road_acc),2) AS decimal(5,2)
		)AS percentage
FROM road_acc
GROUP BY urban_or_rural_area;



WITH Urban_acc AS (
SELECT
		CAST(SUM(CASE
		WHEN urban_or_rural_area = 'Urban' THEN number_of_casualties ELSE 0 END) * 100.0 
		/ NULLIF(SUM(number_of_casualties), 0 )AS DECIMAL(10,2))
		AS [Urban %]
		FROM road_acc
),
Rural_acc AS (
	SELECT 
		CAST(SUM(CASE
		WHEN urban_or_rural_area = 'Rural' THEN number_of_casualties ELSE 0 END) * 100.0 
		/ NULLIF(SUM(number_of_casualties), 0 )AS DECIMAL(10,2))
		AS [Rural %]
		FROM road_acc
) 
	SELECT * FROM Urban_acc, Rural_acc;


	-- Count of Casualties By Light Conditions

SELECT light_conditions, SUM(number_of_casualties) AS Total_casualties
FROM road_acc
GROUP BY light_conditions
ORDER BY total_casualties DESC;


SELECT light_conditions, COUNT(*) AS Count_casualties
FROM road_acc
GROUP BY light_conditions
ORDER BY Count_casualties DESC;


-- Percentage (%) and Segregation of Casualties by Different Light Conditions

SELECT light_conditions,
    SUM(number_of_casualties) AS Total_casualties,
    CAST(ROUND(SUM(number_of_casualties) * 100.0 /
    (SELECT SUM(number_of_casualties) 
		FROM road_acc),2) AS DECIMAL(5,2)
	) AS Percentage
FROM road_acc
GROUP BY light_conditions
ORDER BY Total_casualties DESC;


-- Top 10 Local Authority with Highest Total Number of Casualties

SELECT TOP 10 local_authority,
    SUM(number_of_casualties) AS total_casualties
FROM road_acc
GROUP BY local_authority
ORDER BY total_casualties DESC;