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


--How many trips did the driver cancel ?
select count(*) - sum(driver_not_cancelled) from trip_details;

--How many trips did the customer cancel ?
select count(*) - sum(customer_not_cancelled) from trip_details;

--What is the average distance per trip ?
select * from trips;

select avg(distance) from trips;

--What was the average fare per trip ?
select avg(fare) from trips;

--Total distnace travelled for all the rides
select sum(distance) from trips;

--Which payment method was used the most?
select a.method from payment a
inner join
(select top 1 faremethod, count(distinct tripid) cnt
from trips
group by faremethod
order by count(distinct tripid) desc) b
on a.id = b.faremethod;


--Through which payment mthod was the highest amount paid for the entire day?
select a.method from payment a
inner join
(select top 1 faremethod, sum(fare) fare
from trips
group by faremethod
order by sum(fare) desc)b
on a.id = b.faremethod;


--Which payment method was used to make the payment for the most expensive trip of the day?
select a.method from payment a
inner join
(select top 1 *
from trips
order by fare desc) b
on a.id = b.faremethod;

--Between which two locations had the most no. of trips?
select * from
(select *, dense_rank() over(order by cnt desc)rnk
from
(select loc_from, loc_to, count(tripid) cnt
from trips
group by loc_from, loc_to)a)b
where rnk=1;

--Who were the top 5 earning drivers ?
select * from
(select *, dense_rank() over(order by fare desc) rnk
from
(select driverid, sum(fare) fare
from trips
group by driverid)a)b
where rnk < 6;

--Which duration had most no. of trips ?
select * from
(select *, rank() over(order by cnt desc) rnk
from
(select duration, count(distinct tripid) cnt
from trips
group by duration)a)b
where rnk=1;

--Which driver and customer had more no. of trips?
select * from
(select *, rank() over (order by cnt desc) rnk
from
(select driverid, custid, count(distinct tripid) cnt
from trips
group by driverid, custid)a) b
where rnk=1;

--What is the conversion rate for getting from Search to Estimates ?
select sum(searches_got_estimate) * 100 / sum(searches) from trip_details;
select * from trip_details;
select sum(searches_for_quotes) * 100 / sum(searches_got_estimate) from trip_details;
select sum(searches_got_quotes) * 100 / sum(searches_for_quotes) from trip_details;
select sum(customer_not_cancelled) * 100 / sum(searches_got_quotes) from trip_details;

--Which location got the highest no. of trips during each duration?
select * from
(select *, rank() over(partition by duration order by cnt desc) rnk		--partitioned by duration
from
(select duration, loc_from, count(distinct tripid) cnt from trips
group by duration, loc_from)a)b
where rnk=1;

--Which duration got the highest no. of trips in each of the locations present?
select * from
(select *, rank() over(partition by loc_from order by cnt desc) rnk		--partitioned by location
from
(select duration, loc_from, count(distinct tripid) cnt from trips
group by duration, loc_from)a)b
where rnk=1;

--Which area got the highest no. of fares ?
select * from
(select *, rank() over (order by fare desc) rnk
from
(select loc_from, sum(fare) fare from trips
group by loc_from)a)b
where rnk=1;

--Which area got the highest no. of cancellations ?
--1. Based on driver cancellations
select * from
(select *, rank() over(order by can desc) rnk
from
(select loc_from, count(*) - sum(driver_not_cancelled) can
from trip_details
group by loc_from)a)b
where rnk=1;

--2. Based on customer cancellations
select * from
(select *, rank() over(order by can desc) rnk
from
(select loc_from, count(*) - sum(customer_not_cancelled) can
from trip_details
group by loc_from)a)b
where rnk=1;

--Which duration got the highest no. of trips and highest total of fares?
select * from
(select *, rank() over (order by fare desc) rnk
from
(select duration, sum(fare) fare from trips
group by duration)a)b
where rnk=1;

select * from
(select *, rank() over (order by cnt desc) rnk
from
(select duration, count(distinct tripid) cnt from trips
group by duration)a)b
where rnk=1;



