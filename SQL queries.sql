SELECT * FROM retail_events_db.fact_events;

-- 1.Provide a list of products with a base price greater than 500 and that are featured in promo type of ‘BOGOF’ (Buy One Get One Free).----------

SELECT DISTINCT(p.product_name),base_price
FROM fact_events f
JOIN dim_products p
USING (product_code)
WHERE promo_type='BOGOF' AND base_price > 500;

-- 2.Generate a report that provides an overview of the number of stores in each city.----------------

SELECT city,count(store_id)  as No_of_stores
FROM dim_stores
GROUP BY city 
ORDER BY No_of_stores desc;


-- 3.Generate a report that displays each campaign along with the total revenue generated before and after the campaign---------------------

SELECT campaign_name,sum(revenue_BP),sum(revenue_AP)
FROM dim_campaigns c
JOIN fact_events f
USING (campaign_id)
group by campaign_name;

-- 4.Produce a report that calculates the incremental sold quantity (ISU%) for each category during the Diwali campaign. Additionally, provide rankings for the categories based on their ISU%  --------------------

WITH ISU as (
SELECT P.category,
(sum(`quantity_sold(after_promo)`)-sum(`quantity_sold(before_promo)`))/sum(`quantity_sold(before_promo)`)*100
as ISU_per
FROM dim_products p
JOIN fact_events f
USING (product_code)
JOIN dim_campaigns c
USING (campaign_id)
WHERE c.campaign_name='Diwali'
GROUP BY category) 
SELECT category,ISU_per, rank () over (order by ISU_per desc ) as rank_ISU
from ISU ;

-- 5.Create a report featuring top 5 products, ranked by incremental revenue percentage (IR%), across all campaigns the report will provide essential information including product name, category, and IR%. ----------------

SELECT p.category,p.product_name,
ROUND(sum(incremental_revenue)/sum(revenue_BP)*100,2) as IR_per
FROM dim_products p
JOIN fact_events f
USING (product_code)
GROUP BY p.category,p.product_name
LIMIT 5;

-- 6.which are the Top 10 stores in terms of incremental revenue (IR)generated from the promotions?-------------

SELECT store_id,
CONCAT(ROUND(sum(revenue_AP-revenue_BP)/1000000,2),"M")as IR
from fact_events
group by store_id
order by IR desc
limit 10;


-- 7. which are the Bottom 10 stores in terms of incremental Sold Units (ISU) generated from the promotions?-------------

SELECT store_id,sum(`quantity_sold(after_promo)`-`quantity_sold(before_promo)`) as ISU
from fact_events
group by store_id
order by ISU
limit 10;


-- 8.What are the Top 2 promotion types that resulted in the highest incremental Revenue?------------

SELECT promo_type,
CONCAT(ROUND(sum(revenue_AP-revenue_BP)/1000000,2),"M")as IR
from fact_events
group by promo_type
order by IR  desc
limit 2;


-- 9.What are the Bottom 2 promotion types in terms of their impact on incremental sold units?------------

SELECT promo_type,
sum(`quantity_sold(after_promo)`-`quantity_sold(before_promo)`) as ISU
from fact_events
group by promo_type
order by ISU  
limit 2;

-- 10.which product categories saw the most significant lift in sales from the promotions?----------

SELECT promo_type, sum(`quantity_sold(after_promo)`)-sum(`quantity_sold(before_promo)`)
as ISU
from fact_events
group by promo_type
order by ISU  DESC
limit 2;

-- 11.Are there specific products that respond exceptionally  well or poorly to promotions?-------------

SELECT product_name,IR 
FROM 
(SELECT p.product_name,
CONCAT(ROUND(sum(incremental_revenue)/1000000,2),"M") as IR,
ROW_NUMBER() OVER(ORDER BY sum(incremental_revenue) DESC) AS top_rank,
ROW_NUMBER() OVER(ORDER BY sum(incremental_revenue) ASC) AS Bottom_rank
 FROM dim_products p
JOIN fact_events f
USING (product_code)
GROUP BY p.product_name) as EP
where  top_rank <=3 OR Bottom_rank<=3;






