WITH p AS (
  SELECT * FROM {{ ref('stg_hn_posts') }}
),

stages AS (
  SELECT '1) Created' AS stage, COUNT(*) AS users
  FROM p

  UNION ALL
  SELECT '2) 1+ Upvote', COUNT(*) FROM p WHERE upvotes >= 1

  UNION ALL
  SELECT '3) 10+ Upvotes', COUNT(*) FROM p WHERE upvotes >= 10

  UNION ALL
  SELECT '4) 100+ Upvotes (Viral)', COUNT(*) FROM p WHERE upvotes >= 100
),

final AS (
  SELECT
    stage,
    users,
    ROUND(users / FIRST_VALUE(users) OVER (ORDER BY stage) * 100, 2) AS pct_of_created
  FROM stages
)

SELECT * FROM final
ORDER BY stage