create or replace table `cookie-cats-ab-test.voc_churn_analysis.dim_apps` as
select 
  row_number()over( order by app_name) as app_id,
  app_name
  from (select distinct app_name from `cookie-cats-ab-test.voc_churn_analysis.voc_quick_commerce_cleaned` );

create or replace table `cookie-cats-ab-test.voc_churn_analysis.dim_categories` as
select
 row_number() over( order by issue_category) as category_id,
 issue_category from
 (select distinct issue_category from `cookie-cats-ab-test.voc_churn_analysis.voc_quick_commerce_cleaned`);
 create or replace table `cookie-cats-ab-test.voc_churn_analysis.fact_reviews`as
 select
 generate_uuid() as review_id,
 a.app_id,
 c.category_id,
 s.user_name,
 s.rating,
 s.review_text,
 s.review_time,
 s.app_version
 from `cookie-cats-ab-test.voc_churn_analysis.voc_quick_commerce_cleaned` s
 join `cookie-cats-ab-test.voc_churn_analysis.dim_apps` a 
 on s.app_name=a.app_name
 join `cookie-cats-ab-test.voc_churn_analysis.dim_categories` c
 on s.issue_category=c.issue_category;
