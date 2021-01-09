# ------------------------------------------------------------------------------------------------------------------------------------
# Set Enviroment
# ------------------------------------------------------------------------------------------------------------------------------------
# Create Coal database
CREATE DATABASE Coal;

# Use Coal database
USE Coal;

# ------------------------------------------------------------------------------------------------------------------------------------
# Instructions
# ------------------------------------------------------------------------------------------------------------------------------------

# For ease of use, all queries, per reclaimer diagnostic, should be executed consecutively. 

# ------------------------------------------------------------------------------------------------------------------------------------
# RL1 Diagnostics
# ------------------------------------------------------------------------------------------------------------------------------------
# There are no duplicate dates 
SELECT Dt, Count(Dt) AS 'Count Dt'
FROM rl1
GROUP BY Dt
HAVING 'Count Dt' >= 2;

SELECT *
FROM timeline;

SELECT *
FROM rl1;

# RL1 has no missing dates
SELECT dt.DT, rl1.*
FROM Timeline AS dt LEFT JOIN rl1 AS rl1 
ON dt.DT = rl1.Dt
WHERE rl1.Dt is NULL;

# Add a primary key to allow for rolling window by hour
ALTER TABLE rl1
ADD COLUMN Id int NOT NULL auto_increment primary Key; 

# Create a table with 7 hour rolling window data
CREATE TABLE rl1_rolling_average AS
SELECT Id, Dt, `Nominal Capacity`, `Actual Tonnes`, AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS '7 Day Actual Average',
(`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS 'Rolling Average Difference',
ROUND(((`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) / `Nominal Capacity`) * 100, 2) AS 'Actual Rolling Average %'
FROM rl1;

# List of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
SELECT Id, Dt, `Actual Rolling Average %`
FROM rl1_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6)
ORDER BY id;

# Count of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
SELECT COUNT(*) AS 'Count of Compromised 7 Hour Windows'
FROM rl1_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6);

# Max idle capacity not including the first 6 dates to be consistent with the 7-hour window
SELECT MAX(`Actual Rolling Average %`) AS 'Count of Compromised 7 Hour Windows'
FROM rl1_rolling_average
WHERE Id NOT IN (1,2,3,4,5,6);

# Drop created table
DROP TABLE if exists rl1_rolling_average;

# Drop Id caolumn
ALTER TABLE rl1
DROP COLUMN Id;

# Recommendation:
# The RL1 reclaimer needs maintenance due to the idle capacity exceeding the allowable threshold 28 times within September. 
#
# The RL1 recliamer's idle capacity peaked at 15.92%.

# ------------------------------------------------------------------------------------------------------------------------------------
# RL2 Diagnostics
# ------------------------------------------------------------------------------------------------------------------------------------
# There are no duplicate dates 
SELECT Dt, Count(Dt) AS 'Count Dt'
FROM rl2
GROUP BY Dt
HAVING 'Count Dt' >= 2;

# RL2 has no missing dates
SELECT dt.DT, rl2.*
FROM Timeline AS dt LEFT JOIN rl2 AS rl2 
ON dt.DT = rl2.Dt
WHERE rl2.Dt is NULL;

# Add a primary key to allow for rollowing window by hour
ALTER TABLE rl2
ADD COLUMN Id int NOT NULL auto_increment primary Key; 

# Create a table with 7 hour rolling window data
CREATE TABLE rl2_rolling_average AS
SELECT Id, Dt, `Nominal Capacity`, `Actual Tonnes`, AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS '7 Day Actual Average',
(`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS 'Rolling Average Difference',
ROUND(((`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) / `Nominal Capacity`) * 100, 2) AS 'Actual Rolling Average %'
FROM rl2;

# List of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
SELECT Id, Dt, `Actual Rolling Average %`
FROM rl2_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6)
ORDER BY Id;

# Count of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
SELECT COUNT(*) AS 'Count of Compromised 7 Hour Windows'
FROM rl2_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6);

# Max idle capacity not including the first 6 dates to be consistent with the 7-hour window
SELECT MAX(`Actual Rolling Average %`) AS 'Count of Compromised 7 Hour Windows'
FROM rl2_rolling_average
WHERE Id NOT IN (1,2,3,4,5,6);

# Drop created table
DROP TABLE if exists rl2_rolling_average;

# Drop Id caolumn
ALTER TABLE rl2
DROP COLUMN Id;

# Recommendation:
# The RL2 reclaimer does not need maintenance due to the idle capacity not exceeding the allowable threshold within September.
#
# The RL2 reclaimer's idle capacity peaked at 9.64% and may need maintenance sometime soon.

# ------------------------------------------------------------------------------------------------------------------------------------
# SR1 Diagnostics
# ------------------------------------------------------------------------------------------------------------------------------------
# There are no duplicate dates 
SELECT Dt, Count(Dt) AS 'Count Dt'
FROM sr1
GROUP BY Dt
HAVING 'Count Dt' >= 2;

# SR1 has missing dates
SELECT dt.DT, sr1.*
FROM Timeline AS dt LEFT JOIN sr1 AS sr1
ON dt.DT = sr1.Dt
WHERE sr1.Dt is NULL;

# The SR1 has 96 missing dates
SELECT COUNT(dt.DT) AS 'Count of Missing Dates'
FROM Timeline AS dt LEFT JOIN sr1 AS sr1
ON sr1.DT = dt.DT
WHERE sr1.Dt is NULL;

# Create a variable to replacing missing null values with the SR1's nominal capacity after replacing missing dates
SET @nom = (SELECT AVG(`Nominal Capacity`) FROM sr1);

# Create a table with complete dates and filling in Nominal Capacity with the SR1's nominal capacity and Actual Tonnes with 0
CREATE TABLE sr1_complete_dates AS
SELECT dt.DT, ROUND(IFNULL(sr1.`Nominal Capacity`, @nom),0) AS 'Nominal Capacity', IFNULL(sr1.`Actual Tonnes`,0) AS 'Actual Tonnes'
FROM Timeline AS dt LEFT JOIN sr1 AS sr1
ON sr1.DT = dt.DT
ORDER BY day(dt.DT);

# Add a primary key to allow for rollowing window by hour
ALTER TABLE sr1_complete_dates
ADD COLUMN Id int NOT NULL auto_increment primary Key; 

# Create a table with 7 hour rolling window data
CREATE TABLE sr1_rolling_average AS
SELECT Id, Dt, `Nominal Capacity`, `Actual Tonnes`, AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS '7 Day Actual Average',
(`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS 'Rolling Average Difference',
ROUND(((`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) / `Nominal Capacity`) * 100, 2) AS 'Actual Rolling Average %'
FROM sr1_complete_dates;

# List of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
SELECT Id, Dt, `Actual Tonnes`, `7 Day Actual Average`, `Actual Rolling Average %`
FROM sr1_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6)
ORDER BY Id;

# Count of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
SELECT COUNT(*) AS 'Count of Compromised 7 Hour Windows'
FROM sr1_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6);

# Max idle capacity not including the first 6 dates to be consistent with the 7-hour window
SELECT MAX(`Actual Rolling Average %`) AS 'Count of Compromised 7 Hour Windows'
FROM sr1_rolling_average
WHERE Id NOT IN (1,2,3,4,5,6);

# Drop created table
DROP TABLE if exists sr1_complete_dates;
DROP TABLE if exists sr1_rolling_average;

# Add a primary key to allow for rollowing window by hour
ALTER TABLE sr1
ADD COLUMN Id int NOT NULL auto_increment primary Key; 

# Create a table with 7 hour rolling window data excluding missing dates
# Missing dates are excluded
CREATE TABLE sr1_rolling_average AS
SELECT Id, Dt, `Nominal Capacity`, `Actual Tonnes`, AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS '7 Day Actual Average',
(`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS 'Rolling Average Difference',
ROUND(((`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) / `Nominal Capacity`) * 100, 2) AS 'Actual Rolling Average %'
FROM sr1;

# List of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
# Missing dates are excluded
SELECT Id, Dt, `Actual Tonnes`, `7 Day Actual Average`, `Actual Rolling Average %`
FROM sr1_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6)
ORDER BY Id;

# Count of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
# Missing dates are excluded
SELECT COUNT(*) AS 'Count of Compromised 7 Hour Windows'
FROM sr1_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6);

# Max idle capacity not including the first 6 dates to be consistent with the 7-hour window
# Missing dates are excluded
SELECT MAX(`Actual Rolling Average %`) AS 'Count of Compromised 7 Hour Windows'
FROM sr1_rolling_average
WHERE Id NOT IN (1,2,3,4,5,6);

# Drop created table
DROP TABLE if exists sr1_rolling_average;

# Drop Id caolumn
ALTER TABLE sr1
DROP COLUMN Id;

# Recommendation:
# The SR1 reclaimer needs maintenance due to idle capacity exceeding the allowable threshold 103 times within September.
#
# The SR1 reclaimer's idle capacity peaked at 100.00% due to a significant amount of missing date data.
#
# If we exclude missing date data from the calculations for reasons such as the reclaimer could have been parked or because the exact case 
# for missing date data is currently unknown, the idle capacity only exceeds the allowable threshold 1 time and peaks at 10.34%. 

# ------------------------------------------------------------------------------------------------------------------------------------
# SR4A Diagnostics
# ------------------------------------------------------------------------------------------------------------------------------------
# There are no duplicate dates 
SELECT Dt, Count(Dt) AS 'Count Dt'
FROM sr4A
GROUP BY Dt
HAVING 'Count Dt' >= 2;

# SR4A has missing dates
SELECT dt.DT, sr4a.*
FROM Timeline AS dt LEFT JOIN sr4a AS sr4a
ON dt.DT = sr4a.Dt
WHERE sr4a.Dt is NULL;

# SR4A has 216 missing dates
SELECT COUNT(dt.DT)
FROM Timeline AS dt LEFT JOIN sr4a AS sr4a
ON sr4a.DT = dt.DT
WHERE sr4a.Dt is NULL;

# Create a variable to replacing missing null values with the SR4A's nominal capacity after replacing missing dates
SET @nom = (SELECT AVG(`Nominal Capacity`) FROM sr4a);

# Create a table with complete dates and filling in Nominal Capacity with the SR4A's nominal capacity and Actual Tonnes with 0
CREATE TABLE sr4a_complete_dates AS
SELECT dt.DT, ROUND(IFNULL(sr4a.`Nominal Capacity`, @nom),0) AS 'Nominal Capacity', IFNULL(sr4a.`Actual Tonnes`,0) AS 'Actual Tonnes'
FROM Timeline AS dt LEFT JOIN sr4a AS sr4a
ON sr4a.DT = dt.DT
ORDER BY day(dt.DT);

# Add a primary key to allow for rollowing window by hour
ALTER TABLE sr4a_complete_dates
ADD COLUMN Id int NOT NULL auto_increment primary Key; 

# Create a table with 7 hour rolling window data
CREATE TABLE sr4a_rolling_average AS
SELECT Id, Dt, `Nominal Capacity`, `Actual Tonnes`, AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS '7 Day Actual Average',
(`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS 'Rolling Average Difference',
ROUND(((`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) / `Nominal Capacity`) * 100, 2) AS 'Actual Rolling Average %'
FROM sr4a_complete_dates;

# List of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
SELECT Id, Dt, `Actual Tonnes`, `7 Day Actual Average`, `Actual Rolling Average %`
FROM sr4a_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6)
ORDER BY Id;

# Count of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
SELECT COUNT(*) AS 'Count of Compromised 7 Hour Windows'
FROM sr4a_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6);

# Max idle capacity not including the first 6 dates to be consistent with the 7-hour window
SELECT MAX(`Actual Rolling Average %`) AS 'Count of Compromised 7 Hour Windows'
FROM sr4a_rolling_average
WHERE Id NOT IN (1,2,3,4,5,6);

# Drop created table
DROP TABLE if exists sr4a_complete_dates;
DROP TABLE if exists sr4a_rolling_average;

# Add a primary key to allow for rollowing window by hour
ALTER TABLE sr4a
ADD COLUMN Id int NOT NULL auto_increment primary Key; 

# Create a table with 7 hour rolling window data
# Missing dates are excluded
CREATE TABLE sr4a_rolling_average AS
SELECT Id, Dt, `Nominal Capacity`, `Actual Tonnes`, AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS '7 Day Actual Average',
(`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS 'Rolling Average Difference',
ROUND(((`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) / `Nominal Capacity`) * 100, 2) AS 'Actual Rolling Average %'
FROM sr4a;

# List of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
# Missing dates are excluded
SELECT Id, Dt, `Actual Tonnes`, `7 Day Actual Average`, `Actual Rolling Average %`
FROM sr4a_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6)
ORDER BY Id;

# Count of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
# Missing dates are excluded
SELECT COUNT(*) AS 'Count of Compromised 7 Hour Windows'
FROM sr4a_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6);

# Max idle capacity not including the first 6 dates to be consistent with the 7-hour window
# Missing dates are excluded
SELECT MAX(`Actual Rolling Average %`) AS 'Count of Compromised 7 Hour Windows'
FROM sr4a_rolling_average
WHERE Id NOT IN (1,2,3,4,5,6);

# Drop created table
DROP TABLE if exists sr4a_rolling_average;

# Drop Id caolumn
ALTER TABLE sr4a
DROP COLUMN Id;

# Recommendation:
# The SR4A reclaimer needs maintenance due to idle capacity exceeding the allowable threshold 225 times within September.
#
# The SR4A reclaimer's idle capacity peaked at 100.00% due to a significant amount of missing date data.
#
# If we exclude missing date data from the calculations for reasons such as the reclaimer could have been parked or because the exact case 
# for missing date data is currently unknown, the idle capacity only exceeds the allowable threshold 3 times and peaks at 10.31%. 

# ------------------------------------------------------------------------------------------------------------------------------------
# SR6 Diagnostics
# ------------------------------------------------------------------------------------------------------------------------------------
# There are no duplicate dates 
SELECT Dt, Count(Dt) AS 'Count Dt'
FROM sr6
GROUP BY Dt
HAVING 'Count Dt' >= 2;

# SR6 has no missing dates
SELECT dt.DT, sr6.*
FROM Timeline AS dt LEFT JOIN sr6 AS sr6 
ON dt.DT = sr6.Dt
WHERE sr6.Dt is NULL;

# Add a primary key to allow for rollowing window by hour
ALTER TABLE sr6
ADD COLUMN id int NOT NULL auto_increment primary Key; 

# Create a table with 7 hour rolling window data
CREATE TABLE sr6_rolling_average AS
SELECT Id, Dt, `Nominal Capacity`, `Actual Tonnes`, AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS '7 Day Actual Average',
(`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS 'Rolling Average Difference',
ROUND(((`Nominal Capacity`- AVG(`Actual Tonnes`) OVER(ORDER BY Id ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) / `Nominal Capacity`) * 100, 2) AS 'Actual Rolling Average %'
FROM sr6;

# List of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
SELECT id, Dt, `Actual Rolling Average %`
FROM sr6_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6)
ORDER BY id;

# Count of total 7 hour windows with idle capacity >= 10% not including the first 6 dates to be consistent with the 7-hour window
SELECT COUNT(*) AS 'Count of Compromised 7 Hour Windows'
FROM sr6_rolling_average
WHERE `Actual Rolling Average %` >= 10 AND Id NOT IN (1,2,3,4,5,6);

# Max idle capacity not including the first 6 dates to be consistent with the 7-hour window
SELECT MAX(`Actual Rolling Average %`) AS 'Count of Compromised 7 Hour Windows'
FROM sr6_rolling_average
WHERE Id NOT IN (1,2,3,4,5,6);

# Drop created table
DROP TABLE if exists sr6_rolling_average;

# Drop Id caolumn
ALTER TABLE sr6
DROP COLUMN Id;

# Recommendation:
# The SR6 reclaimer needs maintenance due to idle capacity exceeding the allowable threshold 23 times within September.
#
# # The SR6 reclaimer's idle capacity peaked at 13.04%.



