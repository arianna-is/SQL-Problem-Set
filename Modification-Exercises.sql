-- MOVIE RATING MODIFICATION --

-- 1. Add the reviewer Roger Ebert to your database, with an rID of 209.

INSERT INTO reviewer
VALUES (209, 'Roger Ebert');


-- 2. For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.)

UPDATE movie
SET year = year + 25
WHERE mid IN (
	SELECT mID 
	FROM rating
	GROUP BY mID
	HAVING AVG(stars) >= 4
);


-- 3. Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.

DELETE FROM rating
WHERE stars < 4 AND mID in (
	SELECT mID
	FROM movie
	WHERE year < 1970 OR year > 2000
);


-- SOCIAL NETWORK MODIFICATION -- 

-- 1. It's time for the seniors to graduate. Remove all 12th graders from Highschooler.

DELETE FROM highschooler
WHERE grade = 12;


-- 2. If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.

DELETE FROM likes
WHERE id1 IN(
	SELECT id1 
	FROM likes l1
	WHERE l1.id2 IN (
		SELECT id2
		FROM friend f
		WHERE f.id1 = l1.id1
	) AND l1.id1 NOT IN (
		SELECT id2
		FROM likes l2
		WHERE l2.id1 = l1.id2
	)
);

