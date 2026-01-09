WITH p AS (
  SELECT * FROM {{ ref('stg_hn_posts') }}
  WHERE author IS NOT NULL
),

author_first AS (
  SELECT
    author,
    MIN(created_month) AS cohort_month
  FROM p
  GROUP BY 1
),

ranked_posts AS (
  SELECT
    p.author,
    f.cohort_month,
    p.created_date,
    p.total_engagement,
    p.upvotes,
    p.comments,
    ROW_NUMBER() OVER (PARTITION BY p.author ORDER BY p.created_date) AS post_number
  FROM p p
  JOIN author_first f USING(author)
)

SELECT
  cohort_month,
  post_number,
  COUNT(*) AS posts_in_bucket,
  ROUND(AVG(total_engagement), 2) AS avg_total_engagement,
  ROUND(AVG(upvotes), 2) AS avg_upvotes,
  ROUND(AVG(comments), 2) AS avg_comments
FROM ranked_posts
WHERE post_number <= 10
GROUP BY 1, 2
ORDER BY cohort_month, post_number