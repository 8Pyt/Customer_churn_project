This project was done, being inspired by the available pre-made projects on https://www.analystbuilder.com/projects/saas-revenue-churn-analysis-UPoYs?tab=details. 

The files "monthly_revenue.csv" and "subscription.csv" represent the source files. 

The file "Customer_churn_sql.sql" represents the work SQL file for the execution of the project. 

***Condition and Scopes:***

CloudTask Pro is a SaaS company that has grown from 0 to 600 customers since 2022. While revenue has been growing, the board has raised concerns about a high churn rate. The CFO wants to understand the monthly churn trends, which customer segments are most at risk, and what the company’s unit economics look like (MRR per customer, customer acquisition cost vs. lifetime value). You have access to a subscription-level dataset with customer details, plan info, and churn status, as well as a monthly revenue summary.

Questions to Answer:
1. What is the overall churn rate, and how has the monthly churn rate trended over the past 4 years? Is churn improving or getting worse?
2. Which subscription plan (Starter, Professional, Business, Enterprise) has the highest churn rate? Does billing cycle (monthly vs. annual) significantly impact retention?
3. What are the top 3 reasons customers churn, and do these reasons differ by plan type or company size?
4. Calculate the average Customer Lifetime Value (CLV) by plan. Compare this to the Customer Acquisition Cost (CAC). Which plans are the most and least profitable?

***Results***

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
   
The Average lifespan for each subscription is as follows:
   - Starter:  7 months
   - Profess.: 11 months
   - Business: 15 months
   - Enterpr.: 15 months
   
The unit profit for each additional SKU sold, based on the average lifespan is as follows: 
   - Starter:  $1,229.31
   - Profess.: $4,941.38
   - Business: $22,420.83
   - Enterpr.: $34,715.79
   
The overall profit, based on the average lifespan and number of SKUs sold for each plan is the following: 
   - Starter:  $188,083.93
   - Profess.: $410,134.15
   - Business: $1,479,774.92
   - Enterpr.: $381,873.65
   
***Based on all of the above we can conclude the following steps to improve the churning rate and increase the profits:***
	1. Rethink the startegy for the Starter and Professional Plans. Discounts, longer trials or lowering the price can improve the churning rate, prolong the usage of the tool
    without affecting significantly the profits. 
  2. The main focus should be on the Business Plan, where improving the support quality, offering more trainings, creating more value for the customers via new features
    can help retain customers and significantly increase profits. No price adjustment is needed, increasing the retention results in higer profits. Specific Emphasis should 
    be placed on the app usage in this segment. If the usage drops below 60% proactive feedback sessions might help avoid churning. 
  3. For the Enterprise customers more added value is necessary. Reinvestment into developing new features is necessary to retain customers. 
