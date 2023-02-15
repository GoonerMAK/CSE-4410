drop TABLE COURSE_;
DROP TABLE STUDENT_;
drop table DEPARTMENT_;


-- 1 
CREATE TABLESPACE tbs2
DATAFILE 'tbs2_1_data.dbf' SIZE 2m;

CREATE TABLESPACE tbs3
DATAFILE 'tbs3_data.dbf' SIZE 5m;


-- 2
CREATE USER tablespace_user Identified by t123 default TABLESPACE tbs2;

DROP USER tablespace_user;

alter user tablespace_user QUOTA 1m on tbs2; 

alter user tablespace_user QUOTA 5m on tbs3;


-- 3
CREATE TABLE DEPARTMENT_
(
    name VARCHAR(255),
    id VARCHAR(255),
    CONSTRAINT pk_department PRIMARY KEY (name)
) 
tablespace tbs2;

CREATE TABLE STUDENT_
(
    id VARCHAR(255),
    name VARCHAR(255),
    d_name VARCHAR(255),
    CONSTRAINT pk_student PRIMARY KEY (id),
    CONSTRAINT fk_student foreign KEY (d_name) REFERENCES DEPARTMENT_(NAME)
)
tablespace tbs2;


-- 4
CREATE TABLE COURSE_
( 
    code VARCHAR(255),
    name VARCHAR(255),
    credit VARCHAR(255),
    offer_by VARCHAR(255),
    CONSTRAINT pk_course PRIMARY key (code),
    CONSTRAINT FK_COURSE foreign KEY (offer_by) references DEPARTMENT_(name)
)
tablespace tbs2;


-- 6

SELECT tablespace_name , bytes /1024/1024 MB
FROM dba_free_space
WHERE tablespace_name = 'TBS2';


SELECT tablespace_name , SUM(BYTES)/1024/1024 "FREE SPACE(MB)"
FROM DBA_FREE_SPACE GROUP BY TABLESPACE_NAME;


-- 5 

INSERT INTO DEPARTMENT_ VALUES ('CSE', '1');


INSERT INTO STUDENT_ VALUES ('A', '1', 'CSE');
INSERT INTO STUDENT_ VALUES ('B', '2', 'CSE');
INSERT INTO STUDENT_ VALUES ('C', '3', 'CSE');
INSERT INTO STUDENT_ VALUES ('D', '4', 'CSE');
INSERT INTO STUDENT_ VALUES ('E', '5', 'CSE');
INSERT INTO STUDENT_ VALUES ('F', '6', 'CSE');
INSERT INTO STUDENT_ VALUES ('G', '7', 'CSE');
INSERT INTO STUDENT_ VALUES ('H', '8', 'CSE');


BEGIN
    FOR counter IN 101..10000 loop
        INSERT INTO STUDENT_ VALUES(counter, 'MAK', 'CSE');
    END loop;
END;
/


-- 7 & 8

Alter TABLESPACE tbs2 ADD DATAFILE 'tbs2_data_2.dbf' SIZE 2M;    -- extending via adding data files 

--or 

ALTER DATABASE
DATAFILE 'tbs3_data.dbf' RESIZE 10m;           -- extending via resizing data files


-- 9

SELECT tablespace_name, sum(bytes) / 1024 / 1024 "Size (MB)" 
FROM dba_data_files 
GROUP BY tablespace_name;


-- 10 & 11

DROP TABLESPACE tbs3
INCLUDING CONTENTS AND DATAFILES
CASCADE CONSTRAINTS;


DROP TABLESPACE tbs2
INCLUDING CONTENTS AND DATAFILES
CASCADE CONSTRAINTS;


-- bonus


-- How many tables does each tablespace have

SELECT COUNT(table_name), TABLESPACE_NAME
FROM DBA_TABLES
GROUP by tablespace_name;

-- The tables that a particular tablespace has

SELECT tablespace_name, table_name
from DBA_tables
WHERE tablespace_name = 'TBS2';




--- all done ---