WITH p AS (
  SELECT
    author,
    created_month
  FROM {{ ref('stg_hn_posts') }}
  WHERE author IS NOT NULL
  GROUP BY author, created_month
),

first_month AS (
  SELECT
    author,
    MIN(created_month) AS cohort_month
  FROM p
  GROUP BY 1
),

activity AS (
  SELECT
    p.author,
    f.cohort_month,
    p.created_month,
    DATE_DIFF(p.created_month, f.cohort_month, MONTH) AS month_index
  FROM p
  JOIN first_month f USING(author)
  WHERE DATE_DIFF(p.created_month, f.cohort_month, MONTH) BETWEEN 0 AND 12
),

cohort_sizes AS (
  SELECT cohort_month, COUNT(DISTINCT author) AS cohort_size
  FROM first_month
  GROUP BY 1
),

retained AS (
  SELECT
    cohort_month,
    month_index,
    COUNT(DISTINCT author) AS active_authors
  FROM activity
  GROUP BY 1, 2
)

SELECT
  r.cohort_month,
  r.month_index,
  c.cohort_size,
  r.active_authors,
  ROUND(r.active_authors / c.cohort_size * 100, 2) AS retention_pct
FROM retained r
JOIN cohort_sizes c USING(cohort_month)
ORDER BY cohort_month, month_index