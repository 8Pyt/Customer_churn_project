#First of all I am checking the data

select *
from customer_churn.subscriptions;

select *
from customer_churn.monthly_revenue;

#Checking the churn rate based on the Plan, Billing Cycle, Acquisition Channel, Company Size

select plan, SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END)/COUNT(customer_id) AS pct_churned, COUNT(customer_id)
from customer_churn.subscriptions
group by plan
order by pct_churned desc;

/*Churn ratio based on the plan
Starter	     0.7051	 217
Professional 0.4798	 173
Business	 0.4125	 160
Enterprise	 0.2200	  50
*/
select billing_cycle, SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END)/COUNT(customer_id) AS pct_churned, COUNT(customer_id)
from customer_churn.subscriptions
group by billing_cycle
order by pct_churned desc;

/*Churn ratio based on the billing cycle
Monthly	0.6051	352
Annual	0.4032	248
*/

select acquisition_channel , SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END)/COUNT(customer_id) AS pct_churned, COUNT(customer_id)
from customer_churn.subscriptions
group by acquisition_channel
order by pct_churned desc;

/*Churn ratio based on the aquisition channel
Referral	    0.6129	124
Partner	        0.5800	100
Social Media    0.5577	52
Paid Ads	    0.5304	115
Organic Search	0.4379	153
Direct Sales	0.3929	56
*/

select company_size , SUM(CASE WHEN churned = 'Yes' THEN 1 ELSE 0 END)/COUNT(customer_id) AS pct_churned, COUNT(customer_id)
from customer_churn.subscriptions
group by company_size
order by pct_churned desc;

/*Churn ratio based on the company size
500+	0.6316	38
1-10	0.5669	157
201-500	0.5341	88
11-50	0.5284	176
51-200	0.4255	141
*/

#Thus we can deduct that companies with the Starter Plan, the Monthly Subscription, that got between 1-10 employees or 500+, and got the subscription via referral or via a Partner are at the highest risk of churning. 

#Calculating the Monthly Net Added Contribution (Profit/Loss) from new and churning customers and checking for the lowest and highest values per months:

select result.month, result.added_profit_loss
from (select *, ROUND((new_customers*(avg_revenue_per_customer-customer_acquisition_cost)-churned_customers*avg_revenue_per_customer),2) as added_profit_loss,
(total_active_customers*avg_revenue_per_customer-new_customers*customer_acquisition_cost) as total_cash_flows
from customer_churn.monthly_revenue) as result
order by result.added_profit_loss ASC
LIMIT 3;

/* Months with the most added losses
2025-04-01 00:00:00	-6136.99
2025-05-01 00:00:00	-5058.21
2024-02-01 00:00:00	-2017.85
*/

select result.month, result.added_profit_loss
from (select *, ROUND((new_customers*(avg_revenue_per_customer-customer_acquisition_cost)-churned_customers*avg_revenue_per_customer),2) as added_profit_loss,
(total_active_customers*avg_revenue_per_customer-new_customers*customer_acquisition_cost) as total_cash_flows
from customer_churn.monthly_revenue) as result
order by result.added_profit_loss desc
LIMIT 3;

/* Months with the most added profit
2022-02-01 00:00:00	11307.39
2024-03-01 00:00:00	10787.47
2022-12-01 00:00:00	9885.92
*/

/*Computing the average CLV per plan using average MRR and average customer lifespan.
Comparing CLV to CAC to determine the CLV:CAC ratio.*/

select customer_id, monthly_revenue, plan, signup_date, datediff(str_to_date(churn_date, '%Y-%m-%d'), signup_date)/30 as lifespan 
from customer_churn.subscriptions
where churned = 'Yes';

select count(customer_id), 
	   avg(monthly_revenue), 
       plan, 
       round(avg(datediff(str_to_date(churn_date, '%Y-%m-%d'), signup_date)/30),0) as avg_lifespan,
       round(avg(datediff(str_to_date(churn_date, '%Y-%m-%d'), signup_date)/30)*avg(monthly_revenue),2) as avg_clv
from customer_churn.subscriptions
where churned = 'Yes'
group by plan;

select avg(customer_acquisition_cost) from customer_churn.monthly_revenue;

create table customer_churn.costs_table as select *, 
       (select avg(customer_acquisition_cost) from customer_churn.monthly_revenue) as avg_cac,
       remote_table.avg_clv/(select avg(customer_acquisition_cost) from customer_churn.monthly_revenue) as clv_cac_ratio
from (
select count(customer_id) as count_id, 
	   avg(monthly_revenue) as avg_monthly_revenue, 
       plan, 
       round(avg(datediff(str_to_date(churn_date, '%Y-%m-%d'), signup_date)/30),0) as avg_lifespan,
       round(avg(datediff(str_to_date(churn_date, '%Y-%m-%d'), signup_date)/30)*avg(monthly_revenue),2) as avg_clv
from customer_churn.subscriptions
where churned = 'Yes'
group by plan
) as remote_table;

/* Calculation of the CLV:CAC ratio
count  avg_monthly_revenue  plan          avg_lifespan  avg_clv   avg_cac   clv_cac_ratio
83	   467.40	            Professional  11	        5072.71	  200.04	25.35
153	   204.19	            Starter	      7	            1394.74	  200.04	6.97
66	   1508.05	            Business	  15	        22412.95  200.04	112.04
11	   2327.72	            Enterprise	  15	        34845.3	  200.04	174.19
*/

select *, round((avg_monthly_revenue*avg_lifespan-avg_cac),2) as unit_profit, 
       round(count_id*((avg_monthly_revenue*avg_lifespan)-avg_cac),2) as profit_per_sku
from customer_churn.costs_table
order by profit_per_sku desc, unit_profit desc;

/*
count   avg_monthly_revenue plan          avg_lifespan avg_clv  avg_cac  clv_cac_ratio unit_profit  profit_per_sku
66	    1508.05	            Business	  15	       22412.95 200.04	 112.04	       22420.83	    1479774.92
83	    467.40	            Professional  11	       5072.71	200.04	 25.35	       4941.38	    410134.15
11	    2327.72	            Enterprise	  15	       34845.3	200.04	 174.19	       34715.79	    381873.65
153	    204.19	            Starter	      7	           1394.74	200.04	 6.97	       1229.31	    188083.93
*/

#Analyzing the relationship between feature usage, NPS, and churn.

select nps_score, 
       sum(case when churned = 'Yes' then 1 else 0 end)/count(customer_id) as churn_ratio
from customer_churn.subscriptions
group by nps_score
order by churn_ratio desc;

/* Churn rate based on NPS score
1	0.7745
3	0.7381
2	0.7250
6	0.5714
4	0.5556
5	0.5484
7	0.0000
9	0.0000
8	0.0000
10	0.0000
*/

select case 
			when feature_usage_pct <=20 then '0-20'
			when (feature_usage_pct > 20) AND (feature_usage_pct <= 40) then '21-40'
			when (feature_usage_pct > 40) AND (feature_usage_pct <= 60) then '41-60'
			when (feature_usage_pct > 60) AND (feature_usage_pct <= 80) then '61-80'
			else '81+'
       end as usage_bracket,
       sum(case when churned = 'Yes' then 1 else 0 end)/count(customer_id) as churn_ratio,
       count(customer_id)
from customer_churn.subscriptions
group by usage_bracket
order by churn_ratio desc;

/* Churn rate based on usage
0-20	0.8571	126
21-40	0.6595	232
41-60	0.4228	123
81+	    0.0000	62
61-80	0.0000	57
*/

#Usage percentage of above 60% does not result in churning. Currently only 19.8% of the customer base has a usage percentage higher than this threshold of 60%. 

select case 
			when feature_usage_pct <=20 then '0-20'
			when (feature_usage_pct > 20) AND (feature_usage_pct <= 40) then '21-40'
			when (feature_usage_pct > 40) AND (feature_usage_pct <= 60) then '41-60'
			when (feature_usage_pct > 60) AND (feature_usage_pct <= 80) then '61-80'
			else '81+'
       end as usage_bracket,
       avg(nps_score)
from customer_churn.subscriptions
group by usage_bracket;

/* Average NPS score based on the usage bracket
0-20	3.6667
41-60	4.7967
21-40	3.9052
81+	    5.3871
61-80	5.7368
*/

select sum(case when churned='Yes' then 1 else 0 end)/count(customer_id) as total_churn_rate, 
       sum(case when upgraded='Yes' then 1 else 0 end)/count(customer_id) as total_upgrade_rate
from customer_churn.subscriptions;

#Total churn rate is 0.5217 or 52.17%
#Total upgrade rate is 0.0750 or 7.5% 


select month, monthly_churn_rate_pct
from customer_churn.monthly_revenue;

select churn_reason, count(customer_id) as count
from customer_churn.subscriptions
where churned='Yes'
group by churn_reason
order by count desc
limit 3;

/*Top 3 reasons for churning
Budget Cuts	    53
Price Too High	51
Company Closed	48
*/

select plan,  churn_reason, count(customer_id) as count
from customer_churn.subscriptions
where churned='Yes'
group by plan, churn_reason
order by plan, count desc;

/*For the Starter and Professional Plans it seems that the Top 3 reasons are: 'Price too high', 'Company Closed' and 'Budget Cuts'. Adressing the price might reduce churning. 
For the Business plan it seems that the 'Missing features', 'Poor Support' and 'No longer needed' are the top 2 reasons for churning. Improving support and training for this segment
and adding more value for the price might be a deciding factor. For the Enterprise Plan, there are not that many subscriptions however the reasons are usually the company closure and 
not having enough value to keep the customer long-term. 
*/

select  company_size, churn_reason, count(customer_id) as count
from customer_churn.subscriptions
where churned='Yes'
group by company_size, churn_reason
order by company_size;

/*
In all categories of company sizes the main reasons are budgets cuts, company closure and missing features. 
*/

/*
Results:
1. What is the overall churn rate, and how has the monthly churn rate trended over the past 4 years? Is churn improving or getting worse?
 - The overall churn rate is 52.17%, with an upgrade rate averaging 7.5%. The monthly churn trend is diminishing due to the increased customer base. 

2. Which subscription plan (Starter, Professional, Business, Enterprise) has the highest churn rate? Does billing cycle (monthly vs. annual) significantly impact retention?
 - The Starter Plan has a significantly higher churn rate - 70.51%. The billing cycle divide between the Monthly and the Annual cycle shows a difference between teh churn rate 
 of around 60% for the Monthly one and 40% for the Annual one. 
 
3. What are the top 3 reasons customers churn, and do these reasons differ by plan type or company size?
 - The top 3 reasons for churning are budget cuts, high price or closure of the company. 
 
For the Starter and Professional Plans it seems that the Top 3 reasons are: 'Price too high', 'Company Closed' and 'Budget Cuts'. Adressing the price might reduce churning. 
For the Business plan it seems that the 'Missing features', 'Poor Support' and 'No longer needed' are the top 2 reasons for churning. Improving support and training for this segment
and adding more value for the price might be a deciding factor. For the Enterprise Plan, there are not that many subscriptions however the reasons are usually the company closure and 
not having enough value to keep the customer long-term. 

As general recommendations, rethinking the price startegy, adding more value to the product and improving the support feature for the higher plans might decrease the churning ratio. 

4. Calculate the average Customer Lifetime Value (CLV) by plan. Compare this to the Customer Acquisition Cost (CAC). Which plans are the most and least profitable?
 - The Average lifespan for each subscription is as follows:
   Starter:  7 months
   Profess.: 11 months
   Business: 15 months
   Enterpr.: 15 months
   
The unit profit for each additional SKU sold, based on the average lifespan is as follows: 
   Starter:  $1,229.31
   Profess.: $4,941.38
   Business: $22,420.83
   Enterpr.: $34,715.79
   
The overall profit, based on the average lifespan and number of SKUs sold for each plan is the following: 
   Starter:  $188,083.93
   Profess.: $410,134.15
   Business: $1,479,774.92
   Enterpr.: $381,873.65
   
***Based on all of the above we can conclude the following steps to improve the churning rate and increase the profits:
	1. Rethink the startegy for the Starter and Professional Plans. Discounts, longer trials or lowering the price can improve the churning rate, prolong the usage of the tool
    without affecting significantly the profits. 
    2. The main focus should be on the Business Plan, where improving the support quality, offering more trainings, creating more value for the customers via new features
    can help retain customers and significantly increase profits. No price adjustment is needed, increasing the retention results in higer profits. Specific Emphasis should 
    be placed on the app usage in this segment. If the usage drops below 60% proactive feedback sessions might help avoid churning. 
    3. For the Enterprise customers more added value is necessary. Reinvestment into developing new features is necessary to retain customers. 
*/