-- 1. How many unique post types are found in the 'fact_content' table?
    
    SELECT distinct(post_type) from fact_content;
    
    
-- 2. What are the highest and lowest recorded impressions for each post type? --

     SELECT post_type, max(impressions),min(impressions)from fact_content
     group by post_type;

-- 3. Filter all the posts that were published on a weekend in the month of March and April and export them to a separate csv file. 
  
  SELECT d.month_name,d.weekday_or_weekend,(f.post_category),post_type
  from fact_content f
  JOIN dim_dates d                                        #joined date and fact_content tables using date column
  using (date)
  where weekday_or_weekend="weekend" AND d.month_name in ("March","April");
  
  
-- 4.Create a report to get the statistics for the account. The final output includes the following fields: • month_name • total_profile_visits • total_new_followers

SELECT d.month_name,
sum(profile_visits) as Total_profile_visitors ,
sum(new_followers)  as Total_new_followers
from fact_account                                  # joined fact_account and dim_dates using date column
JOIN dim_dates d
using (date)
group by month_name;

-- 5.Write a CTE that calculates the total number of 'likes’ for each 'post_category' during the month of 'July' and subsequently, arrange the 'post_category' values in descending order according to their total likes.  
  ---- without CTE 
 SELECT d.month_name,f.post_category,sum(likes) as Total_likes
 from fact_content f
 JOIN dim_dates d
 using (date)
 group by post_category, d.month_name
 having month_name ="July"
 order by Total_likes desc;
 
 ----- WITH CTE
 
 With likescount as 
 (
  select month_name,post_category,sum(likes) as Total_likes
  from fact_content f                                         #joined dim_dates and fact content using date column
  JOIN dim_dates d
 using (date)
  group by post_category,month_name                        # group by category and month
 order by Total_likes desc)                              # arranged category by likes by descending order
 
 select * from likescount
 where month_name="July";                              # filtered month as july

 -- 6. Create a report that displays the unique post_category names alongside their respective counts for each month. 

 SELECT month_name,group_concat( distinct(post_category)),count(distinct(post_category))
 from fact_content 
 join dim_dates d
 using (date)
 group by month_name;
 
 -- 7. What is the percentage breakdown of total reach by post type?  The final output includes the following fields:
 
   with reach_per as (
   SELECT post_type,
        SUM(Reach) AS Total_Reach,
        SUM(Impressions) AS Total_Impressions
    FROM fact_content 
    group by post_type)
    
  select * ,
  round((Total_Reach)/(Total_Impressions)*100,2)as reach_per
  from reach_per
  group by post_type;
  getpostshares
  
-- 8.Create a report that includes the quarter, total comments, and total saves recorded for each post category?  

select post_category,sum(comments) as Total_comments,sum(saves) as Total_saves,
            CASE 
            WHEN month_name IN ("January "," February"," March")THEN 'Q1'
            WHEN month_name IN ("April","May","June") THEN 'Q2'
            WHEN month_name IN ("July","August","September") THEN 'Q3'
            ELSE 'Q4'
            End as Quarter
 from dim_dates
 join fact_content
 using (date)
 group by post_category,Quarter;
 
 -- 9. List the top three dates in each month with the highest number of new followers.
 
with top as (
 select month_name,date,new_followers,
 rank() over ( partition by month_name order by new_followers desc )as max
 from dim_dates
 join fact_account 
 using(date)
 )
 select * from top
 where max<=3
order by month_name,max desc;

-- 10.Create a stored procedure that takes the 'Week_no' as input and generates a report displaying the total shares for each 'Post_type'. The output of the procedure should consist of two columns: 
  
  CREATE DEFINER=`root`@`localhost` PROCEDURE `getpostshares`(IN input_week_no varchar(255))
BEGIN
 select post_type,sum(shares) as total_shares
 from fact_content
 join dim_dates 
 using (date)
 where week_no = input_week_no
 group by post_type
 order by total_shares desc;
END
;

CALL getpostshares ('W8');



  

  
  
  

  
  
  
 