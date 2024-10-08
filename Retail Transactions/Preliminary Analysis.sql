select transaction_date,sum(order_amt) FROM retail_transactions group by transaction_date order by transaction_date desc;

select location_state,sum(order_amt) as Total_Revenue FROM retail_transactions group by location_state order by sum(order_amt) desc;

select location_state,location_city,sum(order_amt) as Total_Revenue FROM retail_transactions group by location_state,location_city order by location_state;

select year(transaction_date) as Year_of_Sale,sum(order_amt) from retail_transactions group by year(transaction_date);

select sum(case when rewards_member='true' then 1 else 0 end) as num_reward_members,

sum(case when rewards_member='true' then 1.0 else 0 end)/count(*) *100 as perc_reward_members
from retail_transactions;

select year(transaction_date),sum(case when coupon_flag='Yes' then 1 else 0 end) as num_coupons,
sum(case when coupon_flag='Yes' then 1 else 0 end)/count(*) * 100 as perc_tot_trans
from retail_transactions
group by year(transaction_date);

select sum(case when discount_amt is not null then 1 else 0 end) as total_discount_availed from retail_transactions;

select year(transaction_date) as year_of_purchase,sum(num_of_items) as total_items_sold from retail_transactions group by year(transaction_date);

-- Diagnosis 
select year(transaction_date),count(*) from retail_transactions group by year(transaction_date);

select year(transaction_date),max(transaction_date),min(transaction_date) from retail_transactions group by year(transaction_date);

select month(transaction_date),year(transaction_date),count(*) from retail_transactions group by month(transaction_date),year(transaction_date)
order by year(transaction_date),month(transaction_date);

select coalesce(((order_amt)-(order_amt * discount_amt)),order_amt) as amount_paid from retail_transactions;

select date_part("hour",transaction_hour) as hour_of_day,count(*) as num_transactions from retail_transactions group by date_part("hour",transaction_hour) order by num_transactions desc; 

select year(transaction_date),date_part("hour",transaction_hour) as hour_of_day,count(*) as num_transactions from retail_transactions group by year(transaction_date),date_part("hour",transaction_hour) order by num_transactions desc;

with c as (
select year(transaction_date) as y ,month(transaction_date) as mn,count(*) as cnt from retail_transactions group by month(transaction_date),year(transaction_date)
)
select y,mn as month_of_year,cnt/lag(cnt,1) over(partition by y order by mn) as month_over_month_growth from c order by y,mn

with c1 as (
select year(transaction_date) as y ,month(transaction_date) as mn,count(*) as cnt from retail_transactions group by month(transaction_date),year(transaction_date) order by month(transaction_date),year(transaction_date)
)
select y,mn as month_of_year,cnt/lag(cnt,1) over(order by mn,y) as month_over_month_growth from c1

with c2 as (
select month(transaction_date) as mn,count(*) as cnt from retail_transactions group by month(transaction_date)
)
select mn as month_of_year,cnt/lag(cnt,1) over(order by mn) as month_over_month_growth from c2 order by mn

with tot_rev as (
select location_state,location_city,sum(num_of_items*order_amt*discount_amt) as revenue
rank() over(partition by location_state order by sum(num_of_items*order_amt*discount_amt) desc) as rnk
from retail_transactions
group by location_state,location_city
)
select location_city,location_state,revenue from tot_rev where rnk=1 order by location_state;

with tot_rev as (
select location_state,location_city,sum(num_of_items*order_amt*discount_amt) as revenue,
rank() over(partition by location_state order by sum(num_of_items*order_amt*discount_amt) desc) as rnk
from retail_transactions
group by location_state,location_city) 
select location_city,location_state,revenue from tot_rev where rnk=1 order by location_state;
