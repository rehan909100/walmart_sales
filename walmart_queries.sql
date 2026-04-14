

select * 
from walmart ;

--
select count(*) from walmart ;

select distinct 
  payment_method ,
  count(*)
from walmart 
group by payment_method;

select count(distinct branch)
from walmart ;

select max(quantity) from walmart ;

-- bussiness problems --

-- Q1 What are the different payment methods, and how many transactions and items were sold with each method?--

select distinct 
  payment_method ,
  count(*) as no_payments ,
  sum(quantity) as no_qty_sold
from walmart 
group by payment_method;

-- Q2 Which category received the highest average rating in each branch?-- 

select * from 
(
select 
  branch ,
  category ,
  avg(rating) as avg_rating ,
  rank() over( partition by branch order by avg (rating) desc ) as rnk 
from walmart 
group by 1 , 2
) AS t
where rnk = 1 ;


-- Q3 What is the busiest day of the week for each branch based on transaction  volume? --

select *
from (
SELECT 
Branch ,
    date,
	DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name ,
    count(*) as no_transactions  ,
    rank() over(partition by branch order by count(*) desc) as rnk
FROM walmart
group by 1 , 2) as t
where rnk = 1;

-- Q4 How many items were sold through each payment method? --


select
  payment_method ,
  count(*) as no_payments ,
  sum(quantity) as no_qty_sold
from walmart 
group by payment_method;

-- Q5 What are the average, minimum, and maximum ratings for each category in each city?--
select 
city ,
category ,
min(rating) as min_rating ,
max(rating) as max_rating ,
avg(rating) as avg_rating
from walmart 
group by 1 , 2;

-- Q6 What is the total profit for each category, ranked from highest to lowest? --

SELECT 
category ,
sum(total) as total_revenue ,
sum(total * profit_margin ) as profit 
from walmart
group by 1 ;

-- Q7   What is the most frequently used payment method in each branch?  --


with cte 
as 
(
select 
  branch, 
  payment_method,
  count(*) as total_trans,
  rank() over (partition by branch order by count(*) desc) as rnk
from walmart 
group by 1 ,2 
)
select * 
from cte 
where rnk = 1 ;


-- Q8 How many transactions occur in each shift (Morning, Afternoon, Evening) across branches? --
SELECT 
    branch,
    case 
    when hour(CAST(time AS TIME)) < 12 then 'morning'
    when hour(CAST(time AS TIME)) between 12 and 17 then 'afternoon' 
    else 'evening'
    end day_time ,
    count(*)
FROM walmart
group by 1,2 
order by 1, 3 desc ;

-- Q9 Which branches experienced the largest decrease in revenue compared to the previous year? --

-- rdr == last_rev-cr_rev/ls_rev*100
SELECT *,
       YEAR(STR_TO_DATE(date, '%d/%m/%y')) AS formatted_date
FROM walmart;


WITH revenue_2022 AS (
    SELECT
        branch,
        SUM(total) AS revenue_2022
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT
        branch,
        SUM(total) AS revenue_2023
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY branch
)

SELECT 
    ls.branch,
    ls.revenue_2022 as last_yr_revenue,
    cs.revenue_2023 as cr_yr_revenue,
    round(((ls.revenue_2022 - cs.revenue_2023) /ls.revenue_2022)*100 ,2) as rev_dec
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
ON ls.branch = cs.branch
where ls.revenue_2022 > cs.revenue_2023
order by rev_dec desc
;