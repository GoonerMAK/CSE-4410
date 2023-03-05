DROP TABLE Misconducts CASCADE CONSTRAINTS;
DROP TABLE Transactions CASCADE CONSTRAINTS;
DROP TABLE STUDENTS CASCADE CONSTRAINTS;


CREATE TABLE Students (
  ID NUMBER PRIMARY KEY,
  CGPA NUMBER NOT NULL
);

CREATE TABLE Misconducts (
  SID NUMBER REFERENCES Students(ID),
  Date_time TIMESTAMP NOT NULL
);

CREATE TABLE Transactions (
  SID NUMBER REFERENCES Students(ID),
  Date_time TIMESTAMP NOT NULL,
  amount NUMBER NOT NULL
);

-- Insert values into Students table
INSERT INTO Students (ID, CGPA) VALUES (1, 3.8);
INSERT INTO Students (ID, CGPA) VALUES (2, 4.0);
INSERT INTO Students (ID, CGPA) VALUES (3, 3.6);
INSERT INTO Students (ID, CGPA) VALUES (4, 3.7);

-- Insert values into Misconducts table
INSERT INTO Misconducts (SID, Date_time) VALUES (3, TO_TIMESTAMP('2022-01-01 14:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Misconducts (SID, Date_time) VALUES (4, TO_TIMESTAMP('2022-02-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'));

-- Insert values into Transactions table
INSERT INTO Transactions (SID, Date_time, amount) VALUES (1, TO_TIMESTAMP('2022-03-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 5000);
INSERT INTO Transactions (SID, Date_time, amount) VALUES (2, TO_TIMESTAMP('2022-03-02 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 5000);
INSERT INTO Transactions (SID, Date_time, amount) VALUES (3, TO_TIMESTAMP('2022-03-03 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 5000);



CREATE OR REPLACE FUNCTION distribute_scholarship(scholarship_money NUMBER, per_student_amount NUMBER) 
RETURN VARCHAR2
IS
    selected_students NUMBER := 0;
    disqualified_students NUMBER := 0;
    money number := scholarship_money;
BEGIN
    -- Select all students with CGPA higher than 3.5 and no misconducts
    FOR student IN (SELECT ID, CGPA FROM Students WHERE CGPA > 3.5 AND ID NOT IN (SELECT SID FROM Misconducts))
    LOOP

        -- If there's not enough scholarship money left, stop distributing scholarships
        IF scholarship_money < per_student_amount THEN
            EXIT;
        END IF;
        
        -- If the student is eligible for scholarship money, add a transaction to the Transactions table
        INSERT INTO Transactions (SID, Date_time, amount) VALUES (student.ID, SYSDATE, per_student_amount);
        
        -- Update the total scholarship money available
        money := money - per_student_amount;
        
        -- Increment the count of selected students
        selected_students := selected_students + 1;

    END LOOP;
    
    -- Count the number of disqualified students (students with misconducts)
    SELECT COUNT(*) INTO disqualified_students FROM Misconducts;
    
    -- Return a message with the number of selected and disqualified students
    RETURN 'Selected ' || selected_students || ' students for scholarship, and ' || disqualified_students || ' students were disqualified.';
END;
/


BEGIN
    DBMS_OUTPUT.PUT_LINE(distribute_scholarship(10, 1));
END;
/