-- 1. Find the names of all students who are friends with someone named Gabriel.

SELECT h.name
FROM highschooler h
JOIN friend f ON h.ID = f.ID1
WHERE f.ID2 IN (
  SELECT ID 
  FROM highschooler 
  WHERE name = 'Gabriel'
);


-- 2. For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.

SELECT h1.name, h1.grade, h2.name, h2.grade
FROM highschooler h1
JOIN likes l ON l.ID1 = h1.ID 
JOIN highschooler h2 ON l.ID2 = h2.ID
WHERE (h2.grade + 2) <= h1.grade;


-- 3. For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.

SELECT h1.name, h1.grade, h2.name, h2.grade
FROM highschooler h1
JOIN likes l ON h1.ID = l.ID1
JOIN highschooler h2 ON l.ID2 = h2.ID
JOIN likes l2 ON h2.ID = l2.ID1 AND h1.ID = l2.ID2
WHERE h1.name < h2.name;


-- 4. Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.

SELECT name, grade
FROM highschooler
WHERE id NOT IN  (
  SELECT ID1 
  FROM likes
)
AND id NOT IN (
  SELECT ID2 
  FROM likes
);


-- 5. For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.

SELECT h1.name, h1.grade, h2.name, h2.grade
FROM highschooler h1
JOIN likes l1 ON h1.id = l1.id1
JOIN highschooler h2 ON l1.id2 = h2.ID
WHERE h2.ID NOT IN (
  SELECT ID1 
  FROM likes
);


-- 6. Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade.

SELECT h1.name, h1.grade
FROM highschooler h1
WHERE h1.id NOT IN (
  SELECT f.id1 
  FROM friend f
  JOIN highschooler h2 ON f.id2 = h2.id
  WHERE h1.grade <> h2.grade
)
ORDER BY h1.grade, h1.name;


-- 7. For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C.

SELECT h1.name, h1.grade, h2.name, h2.grade, h3.name, h3.grade
FROM highschooler h1 
JOIN likes l1 ON h1.id = l1.id1
JOIN highschooler h2 ON l1.id2 = h2.id
JOIN friend f1 ON h1.id = f1.id1
JOIN friend f2 ON h2.id = f2.id1
-- check that friend C is friends with both A and B
JOIN highschooler h3 ON h3.id = f1.id2 AND h3.id = f2.id2
-- check that student B who is liked is not friends with student A who likes them
WHERE l1.id2 NOT IN (
  SELECT id2 
  FROM friend
  WHERE id1 = h1.id
);


-- 8. Find the difference between the number of students in the school and the number of different first names.

SELECT COUNT(id) - COUNT(DISTINCT name)
FROM highschooler;


-- 9. Find the name and grade of all students who are liked by more than one other student.

SELECT h1.name, h1.grade
FROM highschooler h1
JOIN likes l ON h1.id = l.id2
GROUP BY l.id2
HAVING COUNT(*) > 1;


-- EXERCISE EXTRAS -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- 1. For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.

SELECT h1.name, h1.grade, h2.name, h2.grade, h3.name, h3.grade
FROM highschooler h1
JOIN likes l1 ON h1.id = l1.id1
JOIN highschooler h2 ON l1.id2 = h2.id
JOIN likes l2 ON h2.id = l2.id1
JOIN highschooler h3 ON l2.id2 = h3.id
WHERE h1.id <> h3.id;


-- 2. Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades.

SELECT h1.name, h1.grade
FROM highschooler h1
WHERE h1.id NOT IN (
  SELECT f.id1 
  FROM friend f
  JOIN highschooler h2 ON f.id2 = h2.id
  WHERE h2.grade = h1.grade
);


-- 3. What is the average number of friends per student? (Your result should be just one number.)

SELECT AVG(ct)
FROM (
  SELECT COUNT(*) ct
  FROM friend
  GROUP BY id1
);


-- 4. Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend.

SELECT COUNT(DISTINCT f1.id2) + COUNT(DISTINCT f2.id2)
FROM highschooler hs
JOIN friend f1 ON hs.id = f1.id1
JOIN friend f2 ON f1.id2 = f2.id1
WHERE hs.name = 'Cassandra'
-- exclude Cassandra from count of friends of friends
AND f2.id2 <> f1.id1
-- exclude Cassandra's friends from count of friends of friends
AND f2.id2 NOT IN (
  SELECT f1.id2
  FROM highschooler hs
  JOIN friend f1 ON hs.id = f1.id1
  WHERE hs.name = 'Cassandra'
);


-- 5. Find the name and grade of the student(s) with the greatest number of friends.

SELECT name, grade
FROM highschooler h
JOIN friend f ON h.id = f.id1
GROUP BY id1
-- compare the number of friends with the maximum number of friends
HAVING COUNT(*) >= (
  SELECT MAX(num)
  FROM (
    SELECT COUNT(*) AS num
    FROM friend
    GROUP BY id1
  )
);
