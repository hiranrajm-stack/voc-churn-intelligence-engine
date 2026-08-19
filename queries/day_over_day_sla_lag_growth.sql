
WITH DailySLADelays AS (
    SELECT 
        a.app_name,
        DATE(f.review_time) AS review_date,
        COUNT(*) AS sla_complaint_count
    FROM `cookie-cats-ab-test.voc_churn_analysis.fact_reviews` f
    JOIN `cookie-cats-ab-test.voc_churn_analysis.dim_apps` a ON f.app_id = a.app_id
    JOIN `cookie-cats-ab-test.voc_churn_analysis.dim_categories` c ON f.category_id = c.category_id
    WHERE c.issue_category = 'SLA & Delivery Delay'
    GROUP BY a.app_name, DATE(f.review_time)
)
SELECT 
    app_name,
    review_date,
    sla_complaint_count,
    LAG(sla_complaint_count, 1, 0) OVER(PARTITION BY app_name ORDER BY review_date) AS prev_day_count,
    sla_complaint_count - LAG(sla_complaint_count, 1, 0) OVER(PARTITION BY app_name ORDER BY review_date) AS day_over_day_change
FROM DailySLADelays
ORDER BY app_name, review_date;

