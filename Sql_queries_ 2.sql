-- 11.Fetch the top 5 athletes who have won the most gold medals.

WITH t1 AS
	(SELECT name, COUNT(name) AS total_medals
	FROM olympics_history
	WHERE medal = 'Gold'
	GROUP BY name
	ORDER BY COUNT(name) DESC),
t2 AS 
	(SELECT *, dense_rank() OVER(ORDER BY total_medals DESC) AS rnk
	FROM t1)
SELECT * 
FROM t2
WHERE rnk <= 5;

-- 12.Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

WITH t1 AS
		(SELECT name, team, count(name) AS total_medals
		FROM olympics_history
		WHERE medal in ('Gold', 'Silver', 'Bronze')
		GROUP BY name, team
		ORDER BY total_medals DESC),
	t2 AS 
		(SELECT *, dense_rank() OVER (order by total_medals desc) AS rnk
		FROM t1)
	SELECT name, team, total_medals
	FROM t2
	WHERE rnk <= 5;
		



	
-- 13.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
	
WITH t1 AS
		(SELECT nr.region, COUNT(1) AS total_medals
		FROM olympics_history AS oh
		JOIN noc_regions AS nr
		ON oh.noc = nr.noc
		WHERE oh.medal <> 'NA'
		GROUP BY nr.region
		ORDER BY total_medals DESC),
	t2 AS 
		(SELECT *, dense_rank() over(order by total_medals desc) AS rnk
		FROM t1)
	SELECT * 
	FROM t2
	WHERE rnk <= 5;
		

-- 14.List down total gold, silver and broze medals won by each country.
-- CREATE extension tablefunc;

SELECT country,
		COALESCE(gold, 0) AS gold,
		COALESCE(silver, 0) AS silver,
		COALESCE(bronze, 0) AS bronze
FROM crosstab	('SELECT nr.region AS country, oh.medal, COUNT(*) AS total_medals
				FROM olympics_history AS oh
				JOIN noc_regions AS nr
				ON oh.noc = nr.noc
				WHERE medal <> ''NA''
				GROUP BY nr.region, oh.medal',
				'values (''Bronze''), (''Gold''), (''Silver'')')
			AS result (country VARCHAR, bronze bigint, gold bigint, silver bigint)
ORDER BY gold DESC, silver DESC, bronze DESC;

-- 15.List down total gold, silver and broze medals won by each country corresponding to each olympic games.


 SELECT substring(games,1,position(' - ' in games) - 1) as games
        , substring(games,position(' - ' in games) + 3) as country
        , coalesce(gold, 0) as gold
        , coalesce(silver, 0) as silver
        , coalesce(bronze, 0) as bronze
    FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
                , medal
                , count(1) as total_medals
                FROM olympics_history oh
                JOIN noc_regions nr ON nr.noc = oh.noc
                where medal <> ''NA''
                GROUP BY games,nr.region,medal
                order BY games,medal',
            'values (''Bronze''), (''Gold''), (''Silver'')')
    AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint);


-- 16.Which countries have never won gold medal but have won silver/bronze medals?

SELECT country, coalesce(gold,0) as gold, coalesce(silver,0) as silver, coalesce(bronze,0) as bronze
    		FROM CROSSTAB('SELECT nr.region as country
    					, medal, count(1) as total_medals
    					FROM OLYMPICS_HISTORY oh
    					JOIN NOC_REGIONS nr ON nr.noc=oh.noc
    					where medal <> ''NA''
    					GROUP BY nr.region,medal order BY nr.region,medal',
                    'values (''Bronze''), (''Gold''), (''Silver'')')
    		AS FINAL_RESULT(country varchar,
    		bronze bigint, gold bigint, silver bigint))
    where gold = 0 and (silver > 0 or bronze > 0)
    order by gold desc nulls last, silver desc nulls last, bronze desc nulls last;


-- 17.In which Sport/event, India has won highest medals.

with t1 AS
	(SELECT sport, COUNT(medal) AS total_medals
	FROM olympics_history
	WHERE medal <> 'NA'
	AND team = 'India'
	GROUP BY sport
	ORDER BY total_medals DESC),
	t2 AS 
	(SELECT *, rank() OVER (order by total_medals desc) AS rnk
	FROM t1)
 SELECT sport, total_medals
 FROM t2
 WHERE rnk = 1;

