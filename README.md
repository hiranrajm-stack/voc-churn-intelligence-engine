# Quick-Commerce VoC Churn Intelligence Engine (Blinkit vs. Zepto)

An end-to-end product analytics project built to analyze customer churn drivers, delivery SLA breaches, and app version stability across **3,000 customer reviews** for quick-commerce apps (Blinkit and Zepto).

The pipeline ingests raw customer review data, cleans and transforms it in **Google BigQuery** using SQL, models it into a **Star Schema**, and serves an interactive dashboard in **Power BI** powered by custom DAX measures.

---

## Key Executive Insights

- **CSAT Benchmark:** Blinkit leads with an average star rating of **4.04**, compared to Zepto's **3.21**.
- **1-Star Churn Rate:** Overall **28.97%** of all analyzed reviews were 1-star complaints.
- **Delivery SLA Bottlenecks:** SLA & Delivery Delays make up **10.47%** of all user complaints across both apps. Zepto registered almost double the delivery complaints of Blinkit (**207 vs. 107**).
- **App Release Risk:** Using a version-level sentiment matrix, version `26.7.2` (Zepto) was identified as a high-risk update, dropping average user ratings by **-0.33 stars** below the baseline.

---

## Tech Stack & Architecture

- **Database / Data Warehouse:** Google BigQuery (SQL)
- **Data Modeling:** Star Schema (1 Fact Table, 2 Dimension Tables)
- **Business Intelligence & DAX:** Power BI Desktop
- **Version Control:** Git & GitHub

---

## Data Model (Star Schema)

The dataset was structured into a Star Schema inside BigQuery to optimize Query speed and simplify Power BI reporting:

1. **`fact_reviews` (Fact Table):** Contains `review_id`, `rating`, `review_text`, `review_time`, `app_version`, `app_id`, and `category_id`.
2. **`dim_apps` (Dimension Table):** Contains `app_id` and `app_name` (Blinkit, Zepto).
3. **`dim_categories` (Dimension Table):** Contains `category_id` and mapped `issue_category` (SLA & Delivery Delay, App UI & Tech Bug, Order Accuracy, Pricing & Refund, General).

---

## DAX Measures Implemented

```dax
// Total Reviews Volume
Total Reviews = COUNTROWS('fact_reviews')

// Overall Average CSAT / Star Rating
Average Rating = AVERAGE('fact_reviews'[rating])

// 1-Star Rate %
1-Star Rate % = 
DIVIDE(
    CALCULATE(COUNTROWS('fact_reviews'), 'fact_reviews'[rating] = 1),
    [Total Reviews],
    0
)

// SLA Share %
SLA Share % = 
DIVIDE(
    CALCULATE(COUNTROWS('fact_reviews'), 'dim_categories'[issue_category] = "SLA & Delivery Delay"),
    [Total Reviews],
    0
)

// Cumulative 1-Star Complaint Velocity
Cumulative 1-Star Reviews = 
VAR CurrentMaxDate = MAX('fact_reviews'[review_time])
RETURN
CALCULATE(
    [1-Star Complaints],
    FILTER(
        ALL('fact_reviews'[review_time]),
        'fact_reviews'[review_time] <= CurrentMaxDate
    )
)

// App Overall Avg Rating
App Overall Avg Rating = 
CALCULATE(
    [Average Rating],
    ALL('fact_reviews'[app_version])
)

// Version Rating Delta vs App Baseline
Version Rating Delta = 
[Average Rating] - [App Overall Avg Rating]
