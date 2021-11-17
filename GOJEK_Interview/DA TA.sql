
select dates.month2020 as month_2020, nvl(src.total_spend,0) as total_spend, nvl(src.customer_count,0) as customer_count, nvl(src.avg_spend_per_user,0.0) as avg_spend_per_user
from
(
select TO_CHAR(booking_time,'MONTH') as booking_month, sum(actual_gmv) as total_spend, count(distinct customer_id) as customer_count, ROUND(sum(actual_gmv)/count(distinct customer_id),2) as avg_spend_per_user
from
(select distinct order_no, customer_id, service_type, booking_time, actual_gmv from orders where service_type = 'GO-SEND-WEB' AND 
EXTRACT(YEAR FROM booking_time) = 2020
) A
group by TO_CHAR(booking_time,'MONTH')
) src

RIGHT JOIN 
(
 select to_char(date '2019-12-01' + numtoyminterval(level,'month'),'MONTH') as month2020
 from dual
connect by level <= 12) dates
on src.booking_month = dates.month2020



MONTH_2020  TOTAL_SPEND CUSTOMER_COUNT  AVG_SPEND_PER_USER
APRIL     310 3 103.33
AUGUST    0 0 0
DECEMBER  0 0 0
FEBRUARY  140 2 70
JANUARY   0 1 0
JULY      0 0 0
JUNE      350 2 175
MARCH     0 0 0
MAY       1350  2 675
NOVEMBER  0 0 0
OCTOBER   0 0 0
SEPTEMBER 0 0 0







with monthly_usage as (
  select 
    customer_id, 
    booking_time - to_date('2019-01-01','yyyy-mm-dd') as time_period
  from orders
  group by customer_id, booking_time - to_date('2019-01-01','yyyy-mm-dd')
  order by customer_id, booking_time - to_date('2019-01-01','yyyy-mm-dd')
  
  ),
 
lag_lead as (
  select customer_id, time_period,
    lag(time_period,1) over (partition by customer_id order by customer_id, time_period) as lag,
    lead(time_period,1) over (partition by customer_id order by customer_id, time_period) as lead
  from monthly_usage),
 
lag_lead_with_diffs as (
  select customer_id, time_period, lag, lead, 
    time_period-lag lag_size, 
    lead-time_period lead_size 
  from lag_lead),
 
calculated as (select time_period,
  case when lag is null then 'NEW'
     when lag_size <= 1 then 'ACTIVE'
     when lag_size > 1 and lag_size <= 6 then 'SOFT CHURN'
     when lag_size > 6 then 'HARD CHURN'
  end as this_month_value,
 
  case when (lead_size > 1 OR lead_size IS NULL) then 'CHURN'
     else NULL
  end as next_month_churn,
 
  count(distinct customer_id) as cnt
   from lag_lead_with_diffs
  group by 1,2,3)
 
select time_period, this_month_value, sum(cnt) 
  from calculated group by 1,2
union
select time_period+1, 'CHURN', cnt 
  from calculated where next_month_churn is not null
order by 1





 WITH dates as 
  (
 select to_char(date '2019-12-01' + numtoyminterval(level,'month'),'mm-yyyy') as month2020, (date '2019-12-01' + numtoyminterval(level,'month')) as dt,
 to_char(((date '2019-12-01' + numtoyminterval(level,'month')) - interval '7' month),'mm-yyyy') as past
 from dual
connect by level <= 12) ,
  
  cte AS ( 
    SELECT  d.month2020, d.dt, d.past, o.customer_id, o.booking_time
    FROM    orders o right outer join   dates d
    on o.booking_time < d.dt
)

SELECT month2020, count(distinct customer_id) as cnt
from cte c
where past = (select to_char(max(booking_time),'mm-yyyy') from cte t where t.customer_id = c.customer_id  and t.booking_time < c.dt)
group by month2020
order by month2020









 WITH dates as 
  (
 select to_char(date '2019-12-01' + numtoyminterval(level,'month'),'mm-yyyy') as month2020, (date '2019-12-01' + numtoyminterval(level,'month')) as dt,
 to_char(((date '2019-12-01' + numtoyminterval(level,'month')) - interval '7' month),'mm-yyyy') as past
 from dual
connect by level <= 12) ,
  
  cte AS ( 
    SELECT  d.month2020, d.dt, d.past, o.customer_id, o.booking_time
    FROM    dates d  left  join orders o
    on o.booking_time < d.dt
)

select s.month2020, NVL(m.cnt,0) as cnt, m.state
from
dates s left join
(
SELECT month2020, count(distinct c.customer_id) as cnt, 'CHURNED' as state
from cte c 
where c.past = (select to_char(max(booking_time),'mm-yyyy') from cte t where t.customer_id = c.customer_id  and t.booking_time < c.dt)
group by month2020
) m
on s.month2020 = m.month2020
order by s.month2020


-------------------- FINAL -----------------------------------------

 WITH dates as 
  (
 select to_char(date '2019-12-01' + numtoyminterval(level,'month'),'mm-yyyy') as month2020, (date '2019-12-01' + numtoyminterval(level,'month')) as dt,
 to_char(((date '2019-12-01' + numtoyminterval(level,'month')) - interval '7' month),'mm-yyyy') as past6month,
 to_char(((date '2019-12-01' + numtoyminterval(level,'month')) - interval '2' month),'mm-yyyy') as past1month
 from dual
connect by level <= 12) ,
  
  cte AS ( 
    SELECT  d.month2020, d.dt, d.past6month, d.past1month, o.customer_id, o.booking_time
    FROM    dates d  left  join orders o
    on o.booking_time < d.dt
)

select s.month2020, NVL(m.cnt,0) as cnt, m.state
from
dates s left join
(
SELECT month2020, count(distinct c.customer_id) as cnt, 'platform hard churn' as state
from cte c 
where c.past6month = (select to_char(max(booking_time),'mm-yyyy') from cte t where t.customer_id = c.customer_id  and t.booking_time < c.dt)
group by month2020

UNION ALL

SELECT month2020, count(distinct c.customer_id) as cnt, 'platform soft churn' as state
from cte c 
where c.past1month = (select to_char(max(booking_time),'mm-yyyy') from cte t where t.customer_id = c.customer_id  and t.booking_time < c.dt)
group by month2020

) m
on s.month2020 = m.month2020
order by s.month2020


------------------------------------------------------------------------------------------





 
WITH dates as 
  (
 select to_char(date '2019-12-01' + numtoyminterval(level,'month'),'mm-yyyy') as month2020, (date '2019-12-01' + numtoyminterval(level,'month')) as dt,
 to_char(((date '2019-12-01' + numtoyminterval(level,'month')) - interval '8' month),'mm-yyyy') as past
 from dual
connect by level <= 12) ,
  
  cte AS ( 
    SELECT  d.month2020, d.dt, d.past, o.customer_id, o.booking_time
    FROM    dates d  left  join orders o
    on o.booking_time < d.dt
),
prev as 
(SELECT month2020, c.customer_id, c.past,  to_char(booking_time,'mm-yyyy')
from cte c 
where c.past = (select to_char(max(booking_time),'mm-yyyy') from cte t where t.customer_id = c.customer_id  and t.booking_time < c.dt))
,latest as
(SELECT month2020, c.customer_id, c.past,  to_char(booking_time,'mm-yyyy')
from cte c 
where c.month2020 = (select to_char(max(booking_time),'mm-yyyy') from cte t where t.customer_id = c.customer_id and t.booking_time < (c.dt + interval '1' month ))),
total as 
(
SELECT to_char(booking_time,'mm-yyyy') as month2020, count(distinct c.customer_id) as total_users
from orders c 
group by to_char(booking_time,'mm-yyyy')
)

select T.month2020 as month_2020, NVL(A.resurrected,0) as reactivated_users, T.total_users, ROUND((NVL(A.resurrected,0) * 100/T.total_users),2) as reactivation_rate_pct
from
(
select l.month2020, count(distinct l.customer_id) as resurrected
from prev p 
inner join 
latest l
on p.month2020 = l.month2020
and p.customer_id = l.customer_id
group by l.month2020) A
right join total T
on A.month2020 = T.month2020
order by T.month2020






select booking_month, count(distinct customer_id) as total_users, sum(reactivation_flag) as reactivated_users, ROUND(sum(reactivation_flag) * 100/ count(distinct customer_id),2) as reactivation_rate_pct
from
(

select distinct customer_id, to_char(booking_time,'mm-yyyy') as booking_month, lag,
case when lag > 182 THEN 1 ELSE 0 END as reactivation_flag
from
( 

select customer_id, booking_time, EXTRACT(DAY FROM (booking_time - lag(booking_time,1,to_date('2100-01-01', 'yyyy-mm-dd')) over (partition by customer_id order by booking_time))) as lag
from orders

) A

) T
group by booking_month
order by booking_month


------------------------------------------------------------------ FINAL

with src as (
select customer_id, booking_time, service_type, EXTRACT(DAY FROM (booking_time - lag(booking_time,1,to_date('2100-01-01', 'yyyy-mm-dd')) over (partition by customer_id order by booking_time))) as lag
from orders
)

select  booking_month, sum(total_users) as total_users, sum(reactivated_users) as reactivated_users, 
ROUND(sum(reactivated_users) * 100/ sum(total_users),2) as reactivation_rate_pct
from
(
select booking_month, service_type, count(distinct customer_id) as total_users, sum(reactivation_flag) as reactivated_users
from
(
select distinct customer_id, service_type, to_char(booking_time,'mm-yyyy') as booking_month, lag,
case when lag > 182 THEN 1 ELSE 0 END as reactivation_flag
from src S

) T
group by booking_month, service_type
) B
group by booking_month


------------------------------------------------------------------------------

with src as (
select customer_id, booking_time, service_type, EXTRACT(DAY FROM (booking_time - lag(booking_time,1,to_date('2100-01-01', 'yyyy-mm-dd')) over (partition by customer_id order by booking_time))) as lag
from orders
)

select  booking_month, service_type, max(reactivation_rate_pct) as max_reactivation_rate_pct
from
(
select booking_month, service_type, count(distinct customer_id) as total_users, sum(reactivation_flag) as reactivated_users, 
ROUND(sum(reactivation_flag) * 100/ count(distinct customer_id),2) as reactivation_rate_pct
from
(
select distinct customer_id, service_type, to_char(booking_time,'mm-yyyy') as booking_month, lag,
case when lag > 182 THEN 1 ELSE 0 END as reactivation_flag
from src S

) T
group by booking_month, service_type
) B
where reactivation_rate_pct > 0
group by booking_month, service_type

















