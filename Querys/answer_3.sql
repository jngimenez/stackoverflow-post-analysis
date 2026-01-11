-- Other than tags, what qualities on a post correlate with the highest rate of answer and
-- approved answer? Feel free to get creative



WITH yearly_coverage AS (
  SELECT
    EXTRACT(YEAR FROM creation_date) AS year,
    COUNT(DISTINCT EXTRACT(MONTH FROM creation_date)) AS months_with_data
  FROM `bigquery-public-data.stackoverflow.posts_questions`
  GROUP BY year
),

latest_complete_year AS (
  SELECT year
  FROM yearly_coverage
  WHERE months_with_data = 12
  ORDER BY year DESC
  LIMIT 1
),

base_questions AS (
  SELECT
    id,
    answer_count,
    accepted_answer_id,
    score,
    EXTRACT(HOUR FROM creation_date) AS creation_hour,
    LENGTH(title) AS title_length,
    LENGTH(body) AS body_length,
    REGEXP_CONTAINS(body, r'<code>') AS has_code_block,
    REGEXP_CONTAINS(body, r'http') AS has_links
  FROM `bigquery-public-data.stackoverflow.posts_questions`
  WHERE EXTRACT(YEAR FROM creation_date) = (SELECT year FROM latest_complete_year)
),

bucketed AS (
  SELECT
    *,
    CASE
      WHEN title_length < 40 THEN 'short'
      WHEN title_length BETWEEN 40 AND 80 THEN 'medium'
      ELSE 'long'
    END AS title_length_bucket,

    CASE
      WHEN body_length < 500 THEN 'short'
      WHEN body_length BETWEEN 500 AND 1500 THEN 'medium'
      ELSE 'long'
    END AS body_length_bucket
  FROM base_questions
)

-- =========================
-- Final Output
-- =========================
SELECT
  title_length_bucket,
  body_length_bucket,
  has_code_block,
  has_links,
  COUNT(*) AS questions,
  SAFE_DIVIDE(COUNTIF(answer_count > 0), COUNT(*)) AS answer_rate,
  SAFE_DIVIDE(
    COUNTIF(accepted_answer_id IS NOT NULL),
    COUNT(*)
  ) AS accepted_answer_rate
FROM bucketed
GROUP BY
  title_length_bucket,
  body_length_bucket,
  has_code_block,
  has_links
HAVING questions >= 100
ORDER BY accepted_answer_rate DESC;