-- For posts which are tagged with only ‘python’ or ‘dbt’
-- , what is the year over year change
-- of question-to-answer ratio for the last 10 years? How about the rate of approved
-- answers on questions for the same time period? How do posts tagged with only ‘python’
-- compare to posts only tagged with ‘dbt’?


/*
Prompt 2
Year-over-year comparison with aligned timelines:
- python_only
- dbt_only
- python_plus_dbt (python + dbt aggregated)
*/

WITH yearly_coverage AS (
  SELECT
    EXTRACT(YEAR FROM creation_date) AS year,
    COUNT(DISTINCT EXTRACT(MONTH FROM creation_date)) AS months_with_data
  FROM `bigquery-public-data.stackoverflow.posts_questions`
  GROUP BY year
),

complete_years AS (
  SELECT year
  FROM yearly_coverage
  WHERE months_with_data = 12
),

analysis_years AS (
  -- last 10 complete years
  SELECT year
  FROM complete_years
  ORDER BY year DESC
  LIMIT 10
),

base_questions AS (
  SELECT
    EXTRACT(YEAR FROM creation_date) AS year,
    answer_count,
    accepted_answer_id,
    SPLIT(tags, '|')[OFFSET(0)] AS tag
  FROM `bigquery-public-data.stackoverflow.posts_questions` q
  JOIN analysis_years y
    ON EXTRACT(YEAR FROM q.creation_date) = y.year
  WHERE ARRAY_LENGTH(SPLIT(tags, '|')) = 1
    AND SPLIT(tags, '|')[OFFSET(0)] IN ('python', 'dbt')
),

-- =========================
-- Metric
-- =========================
python_only AS (
  SELECT
    year,
    'python_only' AS category,
    COUNT(*) AS questions,
    SUM(answer_count) AS total_answers,
    SAFE_DIVIDE(SUM(answer_count), COUNT(*)) AS question_to_answer_ratio,
    SAFE_DIVIDE(COUNTIF(accepted_answer_id IS NOT NULL), COUNT(*))
      AS accepted_answer_rate
  FROM base_questions
  WHERE tag = 'python'
  GROUP BY year
),

dbt_only AS (
  SELECT
    year,
    'dbt_only' AS category,
    COUNT(*) AS questions,
    SUM(answer_count) AS total_answers,
    SAFE_DIVIDE(SUM(answer_count), COUNT(*)) AS question_to_answer_ratio,
    SAFE_DIVIDE(COUNTIF(accepted_answer_id IS NOT NULL), COUNT(*))
      AS accepted_answer_rate
  FROM base_questions
  WHERE tag = 'dbt'
  GROUP BY year
),

python_plus_dbt AS (
  SELECT
    year,
    'python_plus_dbt' AS category,
    COUNT(*) AS questions,
    SUM(answer_count) AS total_answers,
    SAFE_DIVIDE(SUM(answer_count), COUNT(*)) AS question_to_answer_ratio,
    SAFE_DIVIDE(COUNTIF(accepted_answer_id IS NOT NULL), COUNT(*))
      AS accepted_answer_rate
  FROM base_questions
  GROUP BY year
),

unioned AS (
  SELECT * FROM python_only
  UNION ALL
  SELECT * FROM dbt_only
  UNION ALL
  SELECT * FROM python_plus_dbt
)

-- =========================
-- Final Output
-- =========================
SELECT
  year,
  category,
  questions,
  question_to_answer_ratio,
  accepted_answer_rate,
  question_to_answer_ratio
    - LAG(question_to_answer_ratio)
      OVER (PARTITION BY category ORDER BY year) AS yoy_change_q_to_a_ratio,
  accepted_answer_rate
    - LAG(accepted_answer_rate)
      OVER (PARTITION BY category ORDER BY year) AS yoy_change_accepted_rate
FROM unioned
ORDER BY  category ,year desc ;
