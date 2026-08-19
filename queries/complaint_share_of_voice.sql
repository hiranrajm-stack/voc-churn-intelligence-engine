SELECT 
    a.app_name,
    c.issue_category,
    COUNT(*) AS issue_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(PARTITION BY a.app_name), 
        2
    ) AS complaint_share_pct
FROM `cookie-cats-ab-test.voc_churn_analysis.fact_reviews` f
JOIN `cookie-cats-ab-test.voc_churn_analysis.dim_apps` a ON f.app_id = a.app_id
JOIN `cookie-cats-ab-test.voc_churn_analysis.dim_categories` c ON f.category_id = c.category_id
GROUP BY a.app_name, c.issue_category
ORDER BY a.app_name, complaint_share_pct DESC;
