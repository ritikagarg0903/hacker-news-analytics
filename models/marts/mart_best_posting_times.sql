WITH staging AS (
    SELECT * FROM {{ ref('stg_hn_posts') }}
)

SELECT
    -- Extract Day of Week (1=Sunday, 7=Saturday)
    EXTRACT(DAYOFWEEK FROM created_at_utc) as day_of_week,
    -- Extract Hour of Day (0-23)
    EXTRACT(HOUR FROM created_at_utc) as hour_of_day,
    
    COUNT(*) as total_posts,
    ROUND(AVG(upvotes), 1) as avg_upvotes,
    ROUND(AVG(comments), 1) as avg_comments,
    
    -- "Hit Rate": % of posts that got significant traction (>100 upvotes)
    ROUND(COUNTIF(upvotes > 100) / COUNT(*) * 100, 2) as viral_probability_pct

FROM staging
GROUP BY 1, 2
ORDER BY viral_probability_pct DESC
