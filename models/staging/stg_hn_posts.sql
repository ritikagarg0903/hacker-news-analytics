
WITH raw_data AS (
  SELECT
    id AS post_id,
    title,
    url,
    score AS upvotes,
    descendants AS comments,
    `by` AS author,
    timestamp AS created_at_ts,
    type
  FROM {{ source('hacker_news_source', 'full') }}
  WHERE
    timestamp >= '2024-01-01'
    AND type = 'story'
    AND url IS NOT NULL
)

SELECT
  post_id,
  title,
  url,
  author,
  COALESCE(upvotes, 0) AS upvotes,
  COALESCE(comments, 0) AS comments,

 created_at_ts AS created_at_utc,
 DATE(created_at_ts) AS created_date,
DATE_TRUNC(DATE(created_at_ts), WEEK(MONDAY)) AS created_week,
DATE_TRUNC(DATE(created_at_ts), MONTH) AS created_month,

  REGEXP_EXTRACT(url, r'^(?:https?:\/\/)?(?:www\.)?([^\/]+)') AS domain,

  CASE
    WHEN LOWER(title) LIKE 'show hn:%' THEN 'Show HN'
    WHEN LOWER(title) LIKE 'ask hn:%' THEN 'Ask HN'
    ELSE 'News'
  END AS post_type,

  (COALESCE(upvotes, 0) + COALESCE(comments, 0)) AS total_engagement
FROM raw_data