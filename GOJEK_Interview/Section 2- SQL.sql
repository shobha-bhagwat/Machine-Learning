
------- Section 2 - SQL

------ Oracle SQL has been used in all below queries

------ booking_time field is of date format


------- 1. Calculate average spending of GO-SEND users throughout every month of 2020 - 


------- Since every month-yyyy needs to be generated, the "dates" subquery generates continuous months to compensate for any missing dates in the data.  
------- Average spending is considered to be gmv per user i.e. ratio of (total gmv for GO-SEND per month)/(count of customers for GO-SEND for that month)


select dates.month2020 as month_2020, nvl(src.total_spend,0) as total_spend, nvl(src.customer_count,0) as customer_count, nvl(src.avg_spend_per_user,0.0) as avg_spend_per_user 
from
(
select TO_CHAR(booking_time,'MONTH') as booking_month, sum(actual_gmv) as total_spend, count(distinct customer_id) as customer_count, 
ROUND(sum(actual_gmv)/count(distinct customer_id),2) as avg_spend_per_user   ---------- average spend calculation
from
(select distinct order_no, customer_id, service_type, booking_time, actual_gmv from orders where service_type = 'GO-SEND' AND 
EXTRACT(YEAR FROM booking_time) = 2020                  ------- select subset of data for 2020 and GO-SEND service
) A
group by TO_CHAR(booking_time,'MONTH')                 ------- aggregate GMV per month
) src

RIGHT JOIN 
(
 select to_char(date '2019-12-01' + numtoyminterval(level,'month'),'MONTH') as month2020          ------- generates continuous months
 from dual
connect by level <= 12) dates
on src.booking_month = dates.month2020

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


------- 2. Calculate number of “platform hard churn” users and “platform soft churn” users for each month in 2020

------- Here the users whose last transaction was 7-months old (i.e. no transactions in last 6 months) are considered only once in hard churned users list in one month of 2020 
------- i.e. these users are not counted again in the churn list of next month. 
------- Same is the case for soft churned users, their last transaction in 2-month old


 WITH dates as 
  (
 select to_char(date '2019-12-01' + numtoyminterval(level,'month'),'mm-yyyy') as month2020, (date '2019-12-01' + numtoyminterval(level,'month')) as dt,  ------- generate continuous month dates for 2020
 to_char(((date '2019-12-01' + numtoyminterval(level,'month')) - interval '7' month),'mm-yyyy') as past6month,  ------- generate 6-months previous month date
 to_char(((date '2019-12-01' + numtoyminterval(level,'month')) - interval '2' month),'mm-yyyy') as past1month   ------- generate 1-month previous month date
 from dual
 connect by level <= 12) ,
  
 cte AS ( 
    SELECT  d.month2020, d.dt, d.past6month, d.past1month, o.customer_id, o.booking_time          ----------- join orders and dates to account for any missing data, this subquery acts as driver
    FROM    dates d  left  join (select * from orders where booking_time >= to_date('2019-01-01')) o
    on o.booking_time < d.dt
 )

select s.month2020, NVL(m.cnt,0) as cnt, m.state
from
dates s left join
(
SELECT month2020, count(distinct c.customer_id) as cnt, 'platform hard churn' as state             ----------- aggregate hard churn customers per month
from cte c 
where c.past6month = (select to_char(max(booking_time),'mm-yyyy') from cte t where t.customer_id = c.customer_id  and t.booking_time < c.dt)   ----------- count user whose last transaction, older than current month, is 7 months ago
group by month2020

UNION ALL                                                                                          ----------- Union all records to get complete list of both hard & soft churns

SELECT month2020, count(distinct c.customer_id) as cnt, 'platform soft churn' as state              ----------- aggregate soft churn customers per month
from cte c 
where c.past1month = (select to_char(max(booking_time),'mm-yyyy') from cte t where t.customer_id = c.customer_id  and t.booking_time < c.dt)  ----------- count user whose last transaction, older than current month, is 2 months ago
group by month2020

) m
on s.month2020 = m.month2020
order by s.month2020



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------- 3. What is the reactivation rate (those who transacted after labelled churn) of “platform hard churn” users throughout each month of 2020? 

------- For every customer, their bookings are sorted and the interval between each booking date is considered to check if they were previously hard churned users. Default time of '2100-01-01' is considered for comparing interval against first time bookings
------- Reactivation rate (percentage) is calculated as (reactivated users per month)/(total users who made bookings that month)


select booking_month, count(distinct customer_id) as total_users, sum(reactivation_flag) as reactivated_users, 
ROUND(sum(reactivation_flag) * 100/ count(distinct customer_id),2) as reactivation_rate_pct
from
(

	select distinct customer_id, to_char(booking_time,'mm-yyyy') as booking_month, lag,
	case when lag > 182 THEN 1 ELSE 0 END as reactivation_flag                          ------- 182 days is for 6-moth window. In case their last transaction was older than 6 months, we mark those users as reactivated
	from
	( 
		select customer_id, booking_time, EXTRACT(DAY FROM (booking_time - lag(booking_time,1,to_date('2100-01-01', 'yyyy-mm-dd')) over (partition by customer_id order by booking_time))) as lag
		from orders
		where customer_id in (select distinct customer_id from orders where booking_time >= to_date('2020-01-01'))  ----------- for every customer, who made a booking in 2020, we sort their bookings and consider the lag between current booking in 2020 & the previous booking
	) A

) T
group by booking_month
order by booking_month



------- Identify which product helps in reactivation the most in each month. 


with src as (
	select customer_id, booking_time, service_type, EXTRACT(DAY FROM (booking_time - lag(booking_time,1,to_date('2100-01-01', 'yyyy-mm-dd')) over (partition by customer_id order by booking_time))) as lag
	from orders
	where customer_id in (select distinct customer_id from orders where booking_time >= to_date('2020-01-01'))  ----------- for every customer, who made a booking in 2020, we sort their bookings and consider the lag between current booking in 2020 & the previous booking
)

select  booking_month, service_type, max(reactivation_rate_pct) as max_reactivation_rate_pct            ----------------- find service_type with max reactivation rate for that month
from
(
	select booking_month, service_type, count(distinct customer_id) as total_users, sum(reactivation_flag) as reactivated_users,  
	ROUND(sum(reactivation_flag) * 100/ count(distinct customer_id),2) as reactivation_rate_pct
	from
	(
		select distinct customer_id, service_type, to_char(booking_time,'mm-yyyy') as booking_month, lag,    
		case when lag > 182 THEN 1 ELSE 0 END as reactivation_flag                                          ------- 182 days is for 6-moth window. In case their last transaction was older than 6 months, we mark those users as reactivated
		from src S

	) T
	group by booking_month, service_type
) B
where reactivation_rate_pct > 0
group by booking_month, service_type






