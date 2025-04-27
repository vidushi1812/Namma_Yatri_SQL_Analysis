use Namma_Yatri;

--checking columns in 'assembly' table
select * from assembly;

--Since we are getting duplicate records in the result set, we need to check for those records
SELECT ID, Assembly, COUNT(*)
FROM assembly
GROUP BY id, Assembly
HAVING COUNT(*) > 1;

--deleting duplicate records
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ID, Assembly ORDER BY ID) AS rn
    FROM assembly
)
DELETE FROM CTE WHERE rn > 1;

--checking columns in 'duration' table
select * from duration;

--checking if any duplicate records exist
SELECT ID, duration, COUNT(*)
FROM duration
GROUP BY id, duration
HAVING COUNT(*) > 1;

--Deleting duplicate records
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ID, duration ORDER BY ID) AS rn
    FROM duration
)
DELETE FROM CTE WHERE rn > 1;

--checking columns in 'payment' table
select * from payment;

SELECT id, method, COUNT(*)
FROM payment
GROUP BY id, method
HAVING COUNT(*) > 1;

WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ID, method ORDER BY ID) AS rn
    FROM payment
)
DELETE FROM CTE WHERE rn > 1;

--checking columns in 'trip_details' table
select * from trip_details;

SELECT tripid, COUNT(tripid) cnt
FROM trip_details
GROUP BY tripid
HAVING COUNT(tripid) > 1;

WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY tripid, loc_from ORDER BY tripid) AS rn
    FROM trip_details
)
DELETE FROM CTE WHERE rn > 1;

--checking columns in 'trips' table
select * from trips;

SELECT tripid, COUNT(*)
FROM trips
GROUP BY tripid
HAVING COUNT(*) > 1; --as we see in the result set there are no duplicates for this table

--Find the total no. of trips.
select count(distinct tripid) from trip_details;

--Find the total no. of drivers.
select * from trips;

select count(distinct driverid) from trips;

--How much was the total earning ?
select sum(fare) from trips;

-- What are the total no. of completed trips?
select * from trip_details;
select sum(end_ride) from trip_details;

--total searches, total searches which got estimate, total searches for quotes, total searches which got quotes
select sum(searches),sum(searches_got_estimate),sum(searches_for_quotes),sum(searches_got_quotes),
sum(customer_not_cancelled),sum(driver_not_cancelled),sum(otp_entered),sum(end_ride)
from trip_details;





