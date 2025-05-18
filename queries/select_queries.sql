-- Section 1: Basic Summary Statistics

-- 1. How many unique countries are there?
SELECT count(distinct CountryName)
FROM PopStats;

-- 2. How many unique cities are there?
SELECT count(distinct City)
FROM FansPerCity;

-- 3. How many unique languages are there?
SELECT COUNT(DISTINCT LOWER(Language)) AS 'Unique Languages Count'
FROM FansPerLanguage;

-- 4. What is the daily average reach of the posts (i.e. DailyPostsReach) on the global page over the period?
SELECT AVG(DailyPostsReach) AS 'Average Reach Of The Posts'
FROM GlobalPage;

-- 5. What is the daily average engagement rate (i.e. NewLikes) on the global page over the period?
SELECT ROUND(AVG(NewLikes), 2) AS 'Daily Average Engagement'
FROM GlobalPage;


-- Section 2: Location Analysis

-- 6. What are the top 10 countries (considering the number of fans)?
-- Show a table of results containing the following columns: CountryCode, CountryName, NumberOfFans
SELECT ps.CountryCode,
    ps.CountryName,
    fpc.NumberOfFans
FROM PopStats ps
LEFT JOIN FansPerCountry fpc
    ON ps.CountryCode = fpc.CountryCode
WHERE fpc.Date = (
                    SELECT MAX(Date)
                    FROM FansPerCountry
)
ORDER BY fpc.NumberOfFans DESC
LIMIT 10;

-- 7. What are the top 10 countries by penetration ratio (i.e. the % of the country populationthat are fans)?
-- Show a table of results containing the following columns: CountryName, PenetrationRatio, NumberOfFans, Population
SELECT ps.CountryName, (1.0 * fpc.NumberOfFans / ps.Population) * 100 AS PenetrationRatio,
    fpc.NumberOfFans,
    ps.Population
FROM PopStats ps
LEFT JOIN FansPerCountry fpc
    ON ps.CountryCode = fpc.CountryCode
WHERE fpc.Date = (
                    SELECT MAX(Date)
                    FROM FansPerCountry
)
ORDER BY PenetrationRatio DESC
LIMIT 10;

-- 8. What are the bottom 10 cities (considering the number of fans) among countries with a population over 20 million?
-- Show a table of results containing the following columns: CountryName, City, NumberOfFans, Population
SELECT ps.CountryName,
    fpc.City,
    fpc.NumberOfFans,
    ps.Population
FROM PopStats ps
LEFT JOIN FansPerCity fpc
    ON ps.CountryCode = fpc.CountryCode
WHERE fpc.Date = (
                    SELECT MAX(Date)
                    FROM FansPerCity
)
    AND ps.Population > 20000000
ORDER BY fpc.NumberOfFans ASC
LIMIT 10;


-- Section 3: Fan Analysis

-- 9. What is the split of page fans across age groups (in %)?
-- Show a table of results containing the following columns: AgeGroup, PercentageOfFans
SELECT DISTINCT AgeGroup,
    (1.0 * SUM(NumberOfFans) OVER (PARTITION BY AgeGroup) / SUM(NumberOfFans)
        OVER (PARTITION BY Date)) * 100 AS PercentageOfFans
FROM FansPerGenderAge
WHERE Date = (
                SELECT MAX(Date)
                FROM FansPerGenderAge
);

-- 10. What is the split of page fans by gender (in %)?
-- Show a table of results containing the following columns: Gender, PercentageOfFans
SELECT DISTINCT Gender,
    (1.0 * SUM(NumberOfFans) OVER (PARTITION BY Gender) / SUM(NumberOfFans)
        OVER (PARTITION BY Date)) * 100 AS PercentageOfFans
FROM FansPerGenderAge
WHERE Date = (
                SELECT MAX(Date)
                FROM FansPerGenderAge
);


-- Section 4: Language Analysis

-- 11. What is the number of the fans that have declared English as their primary language?
SELECT SUM(NumberOfFans) AS NumberOfEnglishFans
FROM FansPerLanguage
WHERE (
    Date = (
        SELECT MAX(Date)
        FROM FansPerGenderAge
    )
)
AND (LOWER(Language) LIKE 'en');

-- 12. What is the percentage of the fans that have declared English as their primary language?
SELECT PercentageOfFans as PercentageOfEnglishFans
    FROM (SELECT DISTINCT Language,
    (1.0 * SUM(NumberOfFans) OVER (PARTITION BY Language) / SUM(NumberOfFans)
    OVER (PARTITION BY Date)) * 100 AS PercentageOfFans
FROM FansPerLanguage
WHERE Date = (
                SELECT MAX(Date)
                FROM FansPerLanguage
))
WHERE LOWER(Language) LIKE 'en';

-- 13. Based on the number of fans who have declared English as their primary language and living in the US, what is the potential buying power that can be accessed?
SELECT ROUND(fpl.NumberOfFans * (ps.AverageIncome * 0.0001), 2)
    AS PotentialBuyingPowerOfEnglishSpeakers
FROM FansPerLanguage fpl
    NATURAL JOIN PopStats ps
WHERE (LOWER(fpl.Language) LIKE 'en')
    AND
    (LOWER(ps.CountryName) LIKE 'United States')
    AND
    (fpl.Date = (
                    SELECT MAX(Date)
                    FROM FansPerGenderAge
));


-- Section 5: Fan Engagement

-- 14. What is the split of the EngagedFans across the days of the week (monday, tuesday,...)?
-- Give the result as a table with the following columns: DayOfWeek, PercentageSplit
SQL Query
SELECT DISTINCT CASE CAST (STRFTIME('%w', CreatedTime) AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        ELSE 'Saturday' END as DayOfWeek,
    (1.0 * SUM(EngagedFans) OVER(PARTITION BY STRFTIME('%w', CreatedTime)) /
    SUM(EngagedFans) OVER()) * 100 AS PercentageSplit
FROM PostInsights;

-- 15. What is the split of the EngagedFans by time of the day?
-- Give the result as a table with the following columns: TimeRange, Precentage
SELECT DISTINCT TimeRange,
    (1.0 * SUM(EngagedFans) OVER(PARTITION BY TimeRange) / SUM(EngagedFans)
        OVER()) * 100 AS PercentageSplit
FROM (
    SELECT EngagedFans,
        STRFTIME('%H', CreatedTime),
        CASE CAST (STRFTIME('%H', CreatedTime) AS INTEGER)
        WHEN 5 THEN '05:00 - 08:59'
        WHEN 6 THEN '05:00 - 08:59'
        WHEN 7 THEN '05:00 - 08:59'
        WHEN 8 THEN '05:00 - 08:59'
        WHEN 9 THEN '09:00 - 11:59'
        WHEN 10 THEN '09:00 - 11:59'
        WHEN 11 THEN '09:00 - 11:59'
        WHEN 12 THEN '12:00 - 14:59'
        WHEN 13 THEN '12:00 - 14:59'
        WHEN 14 THEN '12:00 - 14:59'
        WHEN 15 THEN '15:00 - 18:59'
        WHEN 16 THEN '15:00 - 18:59'
        WHEN 17 THEN '15:00 - 18:59'
        WHEN 18 THEN '15:00 - 18:59'
        WHEN 19 THEN '19:00 - 21:59'
        WHEN 20 THEN '19:00 - 21:59'
        WHEN 21 THEN '19:00 - 21:59'
        ELSE '22:00 or later' END as TimeRange
    FROM PostInsights
);


-- Section 6: Optional Challenging Queries

-- 16. Compute the change in PostClicks, EngagedFans and Reach from one month to the next.
-- Give the result as a table with the following columns: FromMonth, ToMonth, DeltaPostClicks, DeltaEngagedFans, DeltaReach
WITH MonthlyEngagement AS (
SELECT CAST (STRFTIME('%m', CreatedTime) AS INTEGER) AS MonthNum,
CASE CAST (STRFTIME('%m', CreatedTime) AS INTEGER)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        ELSE 'December' END AS Month,
    SUM(PostClicks) AS MonthPostClicks,
    SUM(EngagedFans) AS MonthEngagedFans,
    SUM(Reach) AS MonthReach
FROM PostInsights
GROUP BY STRFTIME('%m', CreatedTime)
)
SELECT a.Month AS FromMonth,
    b.Month AS ToMonth,
    (1.0 * (b.MonthPostClicks - a.MonthPostClicks) / a.MonthPostClicks) * 100 AS DeltaPostClicks,
    (1.0 * (b.MonthEngagedFans - a.MonthEngagedFans) / a.MonthEngagedFans) * 100 AS DeltaEngagedFans,
    (1.0 * (b.MonthReach - a.MonthReach) / a.MonthReach) * 100 AS DeltaReach
FROM MonthlyEngagement a
    INNER JOIN MonthlyEngagement b ON a.MonthNum = b.MonthNum - 1;