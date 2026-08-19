## Rank issue categories for each app by total complaint volume ##
select a.app_name,c.issue_category,
count(*) as issue_count,
dense_rank()over(partition by a.app_name order by count(*) desc) as category_rank
from `cookie-cats-ab-test.voc_churn_analysis.fact_reviews` f
join `cookie-cats-ab-test.voc_churn_analysis.dim_apps` a
on f.app_id=a.app_id
join `cookie-cats-ab-test.voc_churn_analysis.dim_categories` c
on f.category_id=c.category_id
group by a.app_name,c.issue_category;
