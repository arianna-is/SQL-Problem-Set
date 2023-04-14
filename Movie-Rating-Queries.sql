-- 1. Find the titles of all movies directed by Steven Spielberg.

SELECT title 
FROM Movie 
WHERE director = "Steven Spielberg";


-- 2. Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.

SELECT DISTINCT year 
FROM Movie m 
	JOIN Rating r ON m.mID = r.mID
WHERE stars >= 4
ORDER BY year;


-- 3. Find the titles of all movies that have no ratings.

SELECT title 
FROM Movie
WHERE mID NOT IN (
  SELECT mID FROM Rating
);


-- 4. Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.

SELECT re.name 
FROM Reviewer re
JOIN Rating ra ON re.rID = ra.rID
WHERE ra.ratingDate IS NULL;


-- 5. Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.

SELECT re.name, m.title, ra.stars, ra.ratingDate
FROM Reviewer re 
JOIN Rating ra ON re.rID = ra.rID 
JOIN Movie m ON ra.mID = m.mID
ORDER BY re.name, m.title, ra.stars;


-- 6. For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.

SELECT v.name, m.title
FROM Rating r1 JOIN Rating r2 ON r1.rID = r2.rID AND r1.mID = r2.mID
JOIN Movie m ON m.mID = r1.mID
JOIN Reviewer v ON v.rID = r1.rID
WHERE r2.stars > r1.stars AND r2.ratingDate > r1.ratingDate;


-- 7. For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title.

SELECT m.title, MAX(r.stars)
FROM Movie m JOIN Rating r USING(mID)
GROUP BY m.title
ORDER BY m.title;


-- 8. For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title.

SELECT m.title, (max(r.stars)-min(r.stars)) as rating_spread
FROM Movie m 
JOIN Rating r USING(mID)
GROUP BY rating_spread DESC, m.title;


-- 9. Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.)

SELECT AVG(pre1980.avg) - AVG(post1980.avg)
FROM(
	SELECT avg(r.stars) avg
	FROM Rating r 
  JOIN Movie m USING(mID)
	WHERE m.year > 1980
	GROUP BY mID
) as post1980,(
	SELECT avg(r.stars) avg
	FROM Rating r 
  JOIN Movie m USING(mID)
	WHERE m.year < 1980
	GROUP BY mID
) as pre1980;

------------------------------------------------------------------------------------------------------------------------------------------------
EXERCISE EXTRAS

-- 1. Find the names of all reviewers who rated Gone with the Wind.

SELECT DISTINCT v.name
FROM Reviewer v
JOIN Rating r USING(rID)
JOIN Movie m USING(mID)
WHERE m.title = 'Gone with the Wind';


-- 2. For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.

SELECT v.name, m.title, r.stars
FROM Movie m
JOIN Rating r USING(mID)
JOIN Reviewer v USING(rID)
WHERE v.name = m.director;


-- 3. Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)

SELECT name
FROM Reviewer
UNION
SELECT title
FROM Movie
ORDER BY name;


-- 4. Find the titles of all movies not reviewed by Chris Jackson.

SELECT title FROM Movie
WHERE mID not in
(SELECT mID 
 FROM Rating JOIN Reviewer USING(rID)
 WHERE Reviewer.name = 'Chris Jackson'
);
 

-- 5. For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order.

SELECT DISTINCT MIN(rv.name) mn, MAX(rv.name) mx
FROM Rating r 
JOIN Reviewer rv USING(rID)
GROUP BY r.mID
ORDER BY mn;


-- 6. For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.

SELECT rv.name, m.title, r.stars
FROM Movie m 
JOIN Rating r ON m.mID = r.mID
JOIN Reviewer rv ON r.rid = rv.rid
WHERE r.stars = (SELECT MIN(stars) FROM Rating);


-- 7. List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.

SELECT m.title, AVG(r.stars)
FROM Movie m 
JOIN Rating r USING(mID)
GROUP BY mID
ORDER BY r.stars DESC, m.title;


-- 8. Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.)

SELECT name
FROM Reviewer
WHERE (
  SELECT COUNT(*) 
  FROM Rating 
  WHERE Rating.rID = Reviewer.rID
) >= 3;


-- 9. Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)

SELECT title, director 
FROM Movie
WHERE director IN (
  SELECT director 
  FROM Movie 
  GROUP BY director 
  HAVING COUNT(*) > 1
)
ORDER BY director, title;


-- 10. Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)

SELECT m.title, avg(r.stars) as average
FROM movie m
JOIN rating r
ON m.mid = r.mid
GROUP BY m.title
HAVING average = (
  SELECT MAX(average_stars) 
  FROM (
	  SELECT avg(stars) as average_stars 
	  FROM rating
	  GROUP BY mid
  )
);


-- 11. Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.)

SELECT m.title, AVG(r.stars) average
FROM movie m
JOIN rating r ON m.mid = r.mid
GROUP BY m.title
HAVING average = (
	SELECT MIN(avg_star) 
  FROM(
		SELECT AVG(stars) as avg_star 
		FROM rating
		GROUP BY mID
  )
);
          

-- 12. For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL.

SELECT DISTINCT m.director, m.title, r.stars
FROM movie m 
JOIN rating r USING(mid)
JOIN (
	SELECT m.director, MAX(r.stars) maximum
	FROM movie m 
  JOIN rating r USING(mID)
	WHERE m.director IS NOT NULL
	GROUP BY m.director
	) AS high
ON m.director = high.director AND r.stars = high.maximum;
          
          
          
          
