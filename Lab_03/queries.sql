SET SERVEROUTPUT ON SIZE 1000000

-- 1 
CREATE OR REPLACE PROCEDURE show_movie_time (movie_title IN VARCHAR2) 
AS
    movie_time NUMBER;
    hours NUMBER;
    minutes NUMBER;
    intermission NUMBER;
BEGIN
    SELECT MOV_TIME INTO movie_time
    FROM MOVIE
    WHERE MOV_TITLE = movie_title;

    intermission := floor(movie_time/70) * 15;
    minutes := mod(movie_time + intermission, 60);
    hours := floor((movie_time + intermission) / 60);

    dbms_output.put_line('Movie Title: ' || movie_title);
    dbms_output.put_line('Running Time: ' || hours || ' hours ' || minutes || ' minutes');
END;
/

DECLARE
    movie VARCHAR2(55);
BEGIN
    movie := '&movie';
    show_movie_time(movie);
END ;
/



-- 2

CREATE OR REPLACE PROCEDURE find_top_movies (n IN NUMBER) 
AS
MaxRows Number;
BEGIN

    Select count(*) into MaxRows from (SELECT COUNT(movie.mov_id) 
    FROM movie, rating
    where rating.mov_id = movie.mov_id
    group by movie.mov_title);

    IF( n > MaxRows) THEN dbms_output.put_line('Error.... Invalid rows');
    ELSE
        FOR i IN (select * from (SELECT mov_title, AVG(NVL(rev_stars, 0)) as avgerage_rating
                  FROM movie m, rating r
                  WHERE m.mov_id = r.mov_id
                  GROUP BY m.mov_title
                  ORDER BY avgerage_rating DESC)
                  where ROWNUM <= n)

        LOOP    
            dbms_output.put_line(i.mov_title);
        END LOOP;
    End if;
END;
/   


DECLARE
    N number;
BEGIN
    N := '&N';
    find_top_movies(N);
END ;
/


SELECT mov_title, AVG(NVL(rev_stars, 0)) as avgerage_rating
FROM movie m, rating r
WHERE m.mov_id = r.mov_id
GROUP BY m.mov_title
ORDER BY avgerage_rating DESC;

SELECT COUNT(*) FROM movie m, rating r
WHERE m.mov_id = r.mov_id
GROUP BY m.mov_title ; 

Select count(*) from (SELECT COUNT(movie.mov_id) 
FROM movie, rating
where rating.mov_id = movie.mov_id
group by movie.mov_title);



-- 3

