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

CREATE OR REPLACE FUNCTION get_movie_earnings (id IN NUMBER)
RETURN NUMBER
AS
v_total_earnings NUMBER;
v_num_reviews NUMBER;
v_release_date DATE;
v_current_date DATE;
v_mov_id NUMBER;
BEGIN
    SELECT COUNT(*) as num_reviews, m.mov_id
    INTO v_num_reviews, v_mov_id
    FROM rating r, Movie m
    WHERE r.mov_id = m.mov_id AND r.mov_id = id AND r.rev_stars >= 6
    group by m.mov_id;

    SELECT m.mov_releasedate INTO v_release_date
    FROM movie m
    WHERE m.mov_id = id;

    v_current_date := SYSDATE;

    v_total_earnings := v_num_reviews * 10;

    RETURN v_num_reviews/((v_current_date - v_release_date)/365);
END;
/
    
SELECT get_movie_earnings(901) FROM DUAL;         /* Without user input */


/* With user input */
DECLARE
id number;
BEGIN
id:= '&id';                                      
dbms_output.put_line(get_movie_earnings(id));
end;
/


SELECT COUNT(*) as times , m.mov_id
FROM rating r, movie m
WHERE m.mov_id = r.mov_id AND r.rev_stars >= 6
GROUP BY m.mov_id
ORDER BY mov_id DESC;

SELECT mov_id, mov_title, mov_releasedate from movie Order by mov_releasedate desc;



-- 4

CREATE OR REPLACE FUNCTION get_genre_status (id IN NUMBER)
RETURN VARCHAR2
AS
    gen_title VARCHAR2(20);
    review_count NUMBER;
    avg_rating NUMBER(5,3);
    Genre_Status VARCHAR2(20);
    avg_reviews number(5,3);
    avg_rev_stars number(5,3);
BEGIN

    /* Calculating the average reviews across all genres */
    Select floor(Sum(total_reviews)/count(total_reviews)) INTO avg_reviews   
    from (SELECT g.GEN_TITLE, COUNT(r.REV_ID) as total_reviews
    FROM RATING r
    JOIN MTYPE mt ON r.MOV_ID = mt.MOV_ID
    JOIN GENRES g ON mt.GEN_ID = g.GEN_ID
    GROUP BY g.GEN_TITLE);

    /* Calculating the average reviews given by the reviewers */
    SELECT AVG(NVL(REV_STARS, 0)) INTO avg_rev_stars FROM RATING;


    SELECT GEN_TITLE, COUNT(RATING.REV_ID), AVG(RATING.REV_STARS)
    INTO gen_title, review_count, avg_rating
    FROM GENRES , RATING , MTYPE 
    where GENRES.GEN_ID = MTYPE.GEN_ID AND MTYPE.MOV_ID = RATING.MOV_ID AND GENRES.GEN_ID = MTYPE.gen_id AND  id = GENRES.GEN_ID
    GROUP BY GEN_TITLE;

    IF( review_count > avg_reviews ) THEN 
        IF ( avg_rating < avg_rev_stars ) THEN Genre_Status := 'Widely Watched';
        ELSIF ( avg_rating > avg_rev_stars ) THEN Genre_Status := 'People''s Favorite';  
        END IF;
    
    ELSIF ( review_count < avg_reviews  AND  avg_rating > avg_rev_stars ) THEN Genre_Status := 'Highly Rated';

    ELSE Genre_Status := 'So So';
    END IF; 

    RETURN 'Genre: ' || gen_title || '   Reivew_Count: ' || review_count || '   Average_Rating: ' || avg_rating
            || '    Status: ' || Genre_Status;
END;
/

SELECT get_genre_status(1001) FROM DUAL;         /* Without user input */

DECLARE
id number;
BEGIN
id:= '&id';                                       /* With user input */
dbms_output.put_line(get_genre_status(id));
end;
/


SELECT GEN_TITLE, COUNT(RATING.REV_ID), AVG(RATING.REV_STARS)
FROM GENRES , RATING , MTYPE 
where GENRES.GEN_ID = MTYPE.GEN_ID AND MTYPE.MOV_ID = RATING.MOV_ID AND GENRES.GEN_ID = MTYPE.gen_id
GROUP BY GEN_TITLE;


Select floor(Sum(total_reviews)/count(total_reviews)) as Average_Reviews 
from (SELECT g.GEN_TITLE, COUNT(r.REV_ID) as total_reviews
FROM RATING r
JOIN MTYPE mt ON r.MOV_ID = mt.MOV_ID
JOIN GENRES g ON mt.GEN_ID = g.GEN_ID
GROUP BY g.GEN_TITLE);


SELECT AVG(NVL(REV_STARS, 0)) FROM RATING;



-- 5


CREATE OR REPLACE FUNCTION get_most_frequent_genre (p_start_date DATE, p_end_date DATE)
RETURN VARCHAR2
AS
  v_genre VARCHAR2(20);
  v_count NUMBER;
BEGIN
  SELECT g.gen_title, COUNT(*) as genre_count
  INTO v_genre, v_count
  FROM movie m, mtype mt, genres g
  where  m.mov_id = mt.mov_id AND mt.gen_id = g.gen_id AND m.mov_releasedate 
  BETWEEN p_start_date AND p_end_date
  GROUP BY g.gen_title
  ORDER BY v_count DESC;

  RETURN v_genre || ' (' || v_count || ')';
END;
/

SELECT get_most_frequent_genre(TO_DATE('01-JAN-2020', 'DD-MON-YYYY'), TO_DATE('01-JAN-2021', 'DD-MON-YYYY')) 
FROM DUAL;

SELECT g.gen_title, COUNT(*) as genre_count
  FROM movie m, mtype mt, genres g
  where  m.mov_id = mt.mov_id AND mt.gen_id = g.gen_id AND m.mov_releasedate 
  BETWEEN TO_DATE('01-JAN-1940', 'DD-MON-YYYY') AND TO_DATE('01-JAN-2021', 'DD-MON-YYYY')
  GROUP BY g.gen_title
  ORDER BY genre_count DESC;

  