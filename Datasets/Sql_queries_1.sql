
select * from olympics_history
	
select * from noc_regions

-- 1.How many olympics games have been held?

SELECT COUNT(DISTINCT games) AS total_olympic_games
FROM olympics_history;

-- 2.List down all Olympics games held so far.

SELECT year, season, city
FROM olympics_history
GROUP BY year, season, city
ORDER BY year;

-- 3.Mention the total no of nations who participated in each olympics game?

WITH all_countries AS (
    SELECT oh.games, nr.region
    FROM olympics_history AS oh
    JOIN noc_regions AS nr
    ON oh.noc = nr.noc
    GROUP BY oh.games, nr.region
)

SELECT games, COUNT(*) AS total_countries
FROM all_countries
GROUP BY games
ORDER BY games;



-- 4.Which year saw the highest and lowest no of countries participating in olympics?

WITH all_countries AS 
	(SELECT oh.games, COUNT(nr.region) AS no_of_countries
	FROM olympics_history AS oh
	JOIN noc_regions AS nr
	ON oh.noc = nr.noc
	GROUP BY oh.games,nr.region),

	tot_countries AS 
		(SELECT games, COUNT(1) AS total_countries
		FROM all_countries
		GROUP BY games)

SELECT
    (SELECT games || ' - ' || total_countries 
     FROM tot_countries 
     ORDER BY total_countries ASC LIMIT 1) AS Lowest_Countries,
     
    (SELECT games || ' - ' || total_countries 
     FROM tot_countries 
     ORDER BY total_countries DESC LIMIT 1) AS Highest_Countries;


-- 5.Which nation has participated in all of the olympic games?

WITH tot_games AS (
    SELECT COUNT(DISTINCT games) AS total_games
    FROM olympics_history),
	
countries AS (
    SELECT oh.games, 
        nr.region AS country
    FROM olympics_history AS oh
    JOIN noc_regions AS nr ON oh.noc = nr.noc
    GROUP BY oh.games, nr.region),
	
countries_participated AS (
    SELECT country, 
        COUNT(DISTINCT games) AS total_participated_games
    FROM countries
    GROUP BY country)

SELECT 
    cp.country, 
    cp.total_participated_games, 
    tg.total_games
FROM countries_participated AS cp
JOIN tot_games AS tg ON tg.total_games = cp.total_participated_games
ORDER BY cp.country;



-- 6.Identify the sport which was played in all summer olympics.

WITH t1 AS
	(SELECT COUNT(DISTINCT games) AS total_summer_games
	FROM olympics_history
	WHERE season = 'Summer'),
t2 AS 
	(SELECT DISTINCT sport, games
	FROM olympics_history
	WHERE season = 'Summer'),

t3 AS
	(SELECT sport, COUNT(games) AS no_of_games
	FROM t2
	GROUP BY sport)
SELECT * 
FROM t3
JOIN t1 ON t1.total_summer_games = t3.no_of_games;


	
-- 7.Which Sports were just played only once in the olympics?

WITH t1 AS
	(SELECT DISTINCT games, sport
	FROM olympics_history),
t2 AS 
 	(SELECT sport, COUNT(games) AS no_of_games
	FROM t1
	GROUP BY sport)
SELECT t2.*, t1.games
FROM t2
JOIN t1 ON t1.sport = t2.sport
WHERE t2.no_of_games = 1
ORDER BY t1.sport;

-- 8.Fetch the total no of sports played in each olympic games.

WITH t1 AS 
	(SELECT DISTINCT games, sport
	FROM olympics_history),
t2 AS 
	(SELECT games, COUNT(sport) AS no_of_sports
	FROM t1
	GROUP BY games)
SELECT * 
FROM t2
ORDER BY no_of_sports DESC

-- 9.Fetch details of the oldest athletes to win a gold medal.

WITH temp as 
	(SELECT name,
		sex,
		CAST(case when age = 'NA' then '0' else age end as int) AS age,
		team,
		games,
		city,
		sport,
		event,
		medal
	FROM olympics_history),
ranking as 
		(SELECT *, rank() OVER(order by age DESC) AS rnk
		FROM temp
		WHERE medal = 'Gold')
SELECT *
FROM ranking
WHERE rnk = 1


-- 10.Find the Ratio of male and female athletes participated in all olympic games.

WITH t1 AS
	(SELECT sex, COUNT(sex) AS cnt
	FROM olympics_history
	GROUP BY sex),
t2 AS 
	(SELECT *, row_number() OVER (order by cnt) AS rn
	FROM t1),
min_cnt AS 
	(SELECT cnt FROM t2 WHERE rn = 1),
max_cnt AS 
	(SELECT cnt FROM t2 WHERE rn = 2)
select concat('1 : ', round(max_cnt.cnt::decimal/min_cnt.cnt, 2)) as ratio
from min_cnt, max_cnt;
