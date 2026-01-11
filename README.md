# stackoverflow-post-analysis
Newsela analytics engineer assesment
Candidate Gimenez Jonathan 

############
Prompt 1 – Tag Performance Analysis
############

Question
What tags on a Stack Overflow question lead to the most answers and the highest rate of approved answers for the current year? What tags lead to the least? How about combinations of tags?

Aproach:
I first identified the most recent year with a full 12 months of data to avoid partial-year effects. All results are based on that year only.

From there, I analyzed questions at two levels:
- individual tags
- pairs of tags that appear together on the same question
- Each tag (or tag pair) is evaluated based on how often questions receive answers and how often one of those answers is accepted.

Metrics used:
For both single tags and tag pairs, I calculated:
number of questions
average answers per question
accepted answer rate

To keep results meaningful, I filtered out very small samples:
- at least 100 questions for single tags
- at least 50 questions for tag pairs

Why these choices:
- Using a complete year keeps the comparison fair and up to date.
- Minimum sample sizes help avoid drawing conclusions from outliers.
- Tag pairs are generated in a consistent way to prevent duplicates.

Insights:
- Specific, well-scoped technical tags perform best. Niche tags like google-query-language, xslt-3.0, or stringr show the highest   accepted answer rates, often above 75%, suggesting that narrowly defined questions are easier to resolve.
- Broad or ambiguous tags perform worst. Tags such as linkedin or dolphindb consistently appear among the lowest accepted answer rates, indicating that loosely defined or context-heavy questions are harder to answer conclusively.
-Tag combinations increase volatility. While some tag pairs perform well, the lowest-performing combinations (e.g. dart + webview, ios + video) have accepted answer rates below 10%, highlighting the difficulty of multi-system or integration questions.


############
Prompt 2 – Python & dbt over time
############


Question:
For posts tagged only with python or dbt, how does the question-to-answer ratio and accepted answer rate change year over year over the last 10 years? How do these trends compare?

Aproach:
I first identified the last 10 years with complete data (12 months per year) to ensure year-over-year comparisons are consistent and not affected by partial years.
The analysis focuses only on questions tagged with a single tag (python or dbt) to avoid mixing effects from other topics. This allows for a cleaner comparison between the two ecosystems.
In addition to analyzing python and dbt separately, I also created a combined baseline (python_plus_dbt), which aggregates both tags. This baseline spans the full Python timeline and naturally incorporates dbt in the years where it exists, making it easier to compare long-term trends.

Metrics used:
For each year and category, the following metrics are calculated:
- number of questions
- question-to-answer ratio
- accepted answer rate
Year-over-year changes are computed for both ratios to highlight how engagement and resolution evolve over time.


Why these choices:
- Using only complete years avoids misleading year-over-year deltas.
- Restricting to single-tag questions keeps the comparison focused. 
- The combined baseline helps contextualize dbt within Python’s longer history.

Insights:
-Python shows a clear long-term decline. From 2012 to 2021, both the question-to-answer ratio and accepted answer rate steadily decrease, indicating lower engagement over time despite high volume.
- dbt trends are weak due to limited data. With only two years of data (2020–2021), year-over-year comparisons for dbt are unstable and should be interpreted cautiously.
- python_plus_dbt behaves like Python. Because dbt volume is very small, the combined category is almost entirely driven by Python and does not meaningfully change the overall trend.


############
Prompt 3 – Post qualities correlated with higher answer and accepted answer rates
############

For this analysis, we focused on post characteristics other than tags to understand what makes a question more likely to receive answers and accepted answers.
First, we identified the most recent complete year of Stack Overflow data (a year with all 12 months available) to avoid partial-year bias. All metrics are calculated using only questions from that year.

Each question was then enriched with a set of structural and content related features:

- Title length (short / medium / long)
- Body length (short / medium / long)
- Whether the post contains a code block
- Whether the post includes external links

To make results easier to interpret, title and body lengths were bucketed into simple categories, and metrics were aggregated across all combinations of these features.
Finally, we calculated:

- Answer rate: share of questions with at least one answer
- Accepted answer rate: share of questions with an accepted answer

Low-volume combinations were filtered out (minimum 100 questions) to reduce noise, and results were ordered by accepted answer rate to highlight the strongest-performing post patterns.

Insights:
- Code matters most. Questions with code blocks have much higher answer and accepted-answer rates. The lowest-performing posts almost all lack code.
- Concise questions work better. Short to medium titles and bodies consistently outperform very long posts.
- Links don’t help. Posts with external links tend to have slightly lower answer and acceptance rates than similar self-contained questions.