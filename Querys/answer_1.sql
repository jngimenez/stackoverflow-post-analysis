-- What tags on a Stack Overflow question lead to the most answers and the highest rate
-- of approved answers for the current year? What tags lead to the least? How about
-- combinations of tags?

/*
Determine the most recent COMPLETE year (12 months of data)
*/

WITH yearly_coverage AS (
  -- Measure data completeness per year
  SELECT
    EXTRACT(YEAR FROM creation_date) AS year,
    COUNT(DISTINCT EXTRACT(MONTH FROM creation_date)) AS months_with_data,
    MIN(creation_date) AS first_date,
    MAX(creation_date) AS last_date,
    COUNT(*) AS total_questions
  FROM `bigquery-public-data.stackoverflow.posts_questions`
  GROUP BY year
),

complete_years AS (
  -- A complete year is defined as having data for all 12 months
  SELECT
    year
  FROM yearly_coverage
  WHERE months_with_data = 12
),

analysis_year AS (
  -- Select the most recent complete year
  SELECT
    MAX(year) AS year
  FROM complete_years
),

thresholds AS (
  /*
  Define minimum sample sizes to reduce statistical noise:
  - Single tags: 100+ questions 
  - Tag pairs: 50+ questions 
  */
  SELECT
    100 AS min_questions_single_tag,
    50 AS min_questions_tag_pair
),

base_questions AS (
  -- Questions restricted to the selected complete year
  SELECT
    q.id AS question_id,
    q.answer_count,
    q.accepted_answer_id,
    q.tags
  FROM `bigquery-public-data.stackoverflow.posts_questions` q
  JOIN analysis_year y
    ON EXTRACT(YEAR FROM q.creation_date) = y.year
),

tags_expanded AS (
  -- One row per question per tag
  SELECT
    question_id,
    tag
  FROM base_questions,
  UNNEST(SPLIT(tags, '|')) AS tag
),

-- =========================
-- Single tag 
-- =========================
tag_metrics AS (
  SELECT
    t.tag,
    COUNT(*) AS questions,
    AVG(q.answer_count) AS avg_answers,
    SAFE_DIVIDE(
      COUNTIF(q.accepted_answer_id IS NOT NULL),
      COUNT(*)
    ) AS accepted_answer_rate
  FROM tags_expanded t
  JOIN base_questions q
    ON t.question_id = q.question_id
  CROSS JOIN thresholds th
  GROUP BY t.tag, th.min_questions_single_tag
  HAVING questions >= th.min_questions_single_tag
),

-- =========================
-- Tag pair 
-- =========================
tag_pairs AS (
  SELECT
    t1.question_id,
    t1.tag AS tag_1,
    t2.tag AS tag_2
  FROM tags_expanded t1
  JOIN tags_expanded t2
    ON t1.question_id = t2.question_id
   AND t1.tag < t2.tag
),

tag_pair_metrics AS (
  SELECT
    CONCAT(tag_1, ' + ', tag_2) AS tag_pair,
    COUNT(*) AS questions,
    AVG(q.answer_count) AS avg_answers,
    SAFE_DIVIDE(
      COUNTIF(q.accepted_answer_id IS NOT NULL),
      COUNT(*)
    ) AS accepted_answer_rate
  FROM tag_pairs p
  JOIN base_questions q
    ON p.question_id = q.question_id
  CROSS JOIN thresholds th
  GROUP BY tag_pair, th.min_questions_tag_pair
  HAVING questions >= th.min_questions_tag_pair
)

-- =========================
-- Final Output
-- =========================
SELECT
  'single_tag' AS analysis_type,
  tag AS label,
  questions,
  avg_answers,
  accepted_answer_rate
FROM tag_metrics

UNION ALL

SELECT
  'tag_pair' AS analysis_type,
  tag_pair AS label,
  questions,
  avg_answers,
  accepted_answer_rate
FROM tag_pair_metrics

ORDER BY
  analysis_type,
  accepted_answer_rate DESC;