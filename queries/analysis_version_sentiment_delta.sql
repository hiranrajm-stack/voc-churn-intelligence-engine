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
