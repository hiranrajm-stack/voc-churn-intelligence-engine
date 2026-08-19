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
