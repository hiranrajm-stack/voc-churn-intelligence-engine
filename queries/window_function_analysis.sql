### Rank issue categories for each app by total complaint volume ###
select a.app_name,c.issue_category,
count(*) as issue_count,
dense_rank()over(partition by a.app_name order by count(*) desc) as category_rank
from `cookie-cats-ab-test.voc_churn_analysis.fact_reviews` f
join `cookie-cats-ab-test.voc_churn_analysis.dim_apps` a
on f.app_id=a.app_id
join `cookie-cats-ab-test.voc_churn_analysis.dim_categories` c
on f.category_id=c.category_id
group by a.app_name,c.issue_category;



### Calculate each app version's average rating alongside the app's overall average rating to highlight buggy updates ###

WITH VersionStats AS (
    SELECT 
        a.app_name,
        f.app_version,
        AVG(f.rating) AS version_avg_rating,
        COUNT(*) AS version_review_count
    FROM `cookie-cats-ab-test.voc_churn_analysis.fact_reviews` f
    JOIN `cookie-cats-ab-test.voc_churn_analysis.dim_apps` a ON f.app_id = a.app_id
    WHERE f.app_version IS NOT NULL
    GROUP BY a.app_name, f.app_version
)
SELECT 
    app_name,
    app_version,
    ROUND(version_avg_rating, 2) AS version_avg_rating,
    ROUND(AVG(version_avg_rating) OVER (PARTITION BY app_name), 2) AS overall_app_avg,
    ROUND(version_avg_rating - AVG(version_avg_rating) OVER (PARTITION BY app_name), 2) AS rating_delta
FROM VersionStats
ORDER BY app_name, version_review_count DESC;


#### Track the running total of 1-star reviews for each app sorted by review date ###

WITH Daily1StarReviews AS (
    SELECT 
        a.app_name,
        DATE(f.review_time) AS review_date,
        COUNT(*) AS daily_1star_count
    FROM `cookie-cats-ab-test.voc_churn_analysis.fact_reviews` f
    JOIN `cookie-cats-ab-test.voc_churn_analysis.dim_apps` a ON f.app_id = a.app_id
    WHERE f.rating = 1
    GROUP BY a.app_name, DATE(f.review_time)
)
SELECT 
    app_name,
    review_date,
    daily_1star_count,
    SUM(daily_1star_count) OVER (
        PARTITION BY app_name 
        ORDER BY review_date
    ) AS cumulative_1star_reviews
FROM Daily1StarReviews
ORDER BY app_name, review_date;


