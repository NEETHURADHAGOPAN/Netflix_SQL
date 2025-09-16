-- Netflix Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(show_id VARCHAR(6),
type VARCHAR(10),
title VARCHAR(120),
director VARCHAR(210) ,
casts VARCHAR(1000),
country VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(15),	
listed_in VARCHAR(100),
description VARCHAR(250)
);

SELECT *
FROM netflix;

-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT type,COUNT(*) AS total_count
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

WITH T1 AS
(SELECT type,rating,COUNT(*) AS total_count,
DENSE_RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS rnk
FROM netflix
GROUP BY rating,type)

SELECT type,rating,total_count
FROM T1
WHERE rnk=1; 

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT title,release_year 
FROM netflix
WHERE release_year=2020 AND type='Movie';

-- 4. Find the top 5 countries with the most content on Netflix

SELECT TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS new_country,
COUNT(*) AS content_count 
FROM netflix
GROUP BY new_country
order by 2 DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT title, CAST(REPLACE(duration,' min','') AS INT) AS max_length
FROM netflix
WHERE type='Movie' AND duration <>'null'
ORDER BY 2 DESC
LIMIT 1;

-- 6. Find content added FROM 2016-2021

SELECT type, title,
EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year
FROM netflix
WHERE EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY'))
BETWEEN ((SELECT MAX(EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')))
           FROM netflix) - 5)
AND (SELECT MAX(EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')))
FROM netflix)
ORDER BY 3;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT type,title
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE type='TV Show' AND 
CAST(SPLIT_PART(duration,' ',1) AS INT)>5 ;

-- 9. Count the number of content items in each genre

SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS genre,COUNT(*) 
FROM netflix
GROUP BY 1;


-- 10.Find each year and the average numbers of content release 
-- in India on netflix.Return top 5 year with highest avg content release!


SELECT EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')) AS year,
COUNT(*) AS yearly_content,
ROUND(COUNT(*)::numeric 
    / (SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%')::numeric * 100,
    2) AS avg_percentage
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1 
ORDER BY 3 DESC;


-- 11. List all movies that are documentaries

SELECT title AS movie_name
FROM netflix
WHERE listed_in ILIKE '%Documentaries%'
AND type='Movie';

-- 12. Find all content without a director

SELECT * 
FROM netflix
WHERE director IS null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT  title AS movies,release_year,casts 
FROM netflix
WHERE casts ILIKE '%Salman Khan%' 
AND release_year> EXTRACT (YEAR FROM(CURRENT_DATE))-10;

-- 14. Find the top 10 actors who have appeared in the highest 
-- number of movies produced in India.

SELECT TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) AS actors,
COUNT(*) as films_appeared
FROM netflix
WHERE country ILIKE '%India%' and type='Movie'
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 10;


-- 15.Categorize the content based on the presence of the keywords 
-- 'kill' and 'violence' in the description field. Label content 
-- containing these keywords as 'Bad' and all other content as 'Good'. 
-- Count how many items fall into each category.


SELECT 
(CASE WHEN description ~* '\mkill' 
OR description ILIKE '%violence%' THEN 'Bad_Content' ELSE 'Good_Content' END) 
AS label, COUNT(*) 
FROM netflix
GROUP BY 1;



