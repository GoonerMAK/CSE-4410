DROP table Salary CASCADE CONSTRAINTS;
DROP table AirportsLog CASCADE CONSTRAINTS; 
DROP table Citizen CASCADE CONSTRAINTS;


CREATE TABLE Citizen
(
    ID number,
    name VARCHAR(255),
    DOB Date,
    CONSTRAINT PK_Citizen PRIMARY KEY(ID)
);

CREATE TABLE Salary
(
    CID number,
    DT Date,
    Amount number,
    CONSTRAINT FK_Salary FOREIGN KEY (CID) REFERENCES Citizen(ID),
    CONSTRAINT PK_Salary PRIMARY KEY (CID, DT)
);

CREATE TABLE AirportsLog
(
    DT Date,
    type VARCHAR(255),             /* departure or arrival */
    destination VARCHAR(255),
    CONSTRAINT PK_BALANCE PRIMARY KEY (dt, type)
);



    /* With Cursors */

CREATE OR REPLACE FUNCTION evaluate_status(citizen_id NUMBER)
RETURN VARCHAR2
AS
  average_salary NUMBER;
  total_departures NUMBER;
  
  CURSOR salary_cursor IS
    SELECT s.amount
    FROM salary s
    WHERE s.cid = citizen_id AND
    s.dt BETWEEN ADD_MONTHS(SYSDATE, -60) AND SYSDATE;   /* ADD_MONTHS function is used to return a date with a specified number of months added to it */

  CURSOR departure_cursor IS
    SELECT a.destination
    FROM AirportsLog a
    WHERE a.destination IS NOT NULL
    AND a.dt BETWEEN ADD_MONTHS(SYSDATE, -60) AND SYSDATE;     /* 5 years = 12*5 = 60 months */

BEGIN
  -- Calculating the average salary for the last 5 years
  average_salary := 0;
  FOR salary_record IN salary_cursor LOOP
    average_salary := average_salary + salary_record.amount;
  END LOOP;
  average_salary := FLOOR(average_salary / 5);
  
  -- Calculating the total departures in the last 5 years
  total_departures := 0;
  FOR departure_record IN departure_cursor LOOP
    total_departures := total_departures + 1;
  END LOOP;
  
  -- Evaluate the status based on the average salary and total departures
  IF average_salary > 100000 AND total_departures >= 10 THEN
    RETURN 'CIP';
  ELSIF average_salary BETWEEN 50000 AND 100000 AND total_departures >= 5 THEN
    RETURN 'VIP';
  ELSE
    RETURN 'ORDINARY';
  END IF;
END;
/


DECLARE
  status VARCHAR2(10);
BEGIN
  status := evaluate_status(1);
  DBMS_OUTPUT.PUT_LINE('Citizen status: ' || status);
END;
/

    
    /* Without Cursors */

CREATE OR REPLACE FUNCTION evaluate_status(citizen_id NUMBER)
RETURN VARCHAR2
AS
  average_salary NUMBER;
  total_departures NUMBER;
BEGIN
  -- Calculating the average salary for the last 5 years
  SELECT AVG(s.amount) INTO average_salary
  FROM salary s
  WHERE s.cid = citizen_id
  AND s.dt BETWEEN ADD_MONTHS(SYSDATE, -60) AND SYSDATE;
  
  -- Calculating the total departures in the last 5 years
  SELECT COUNT(*) INTO total_departures
  FROM airportslog a
  WHERE a.destination IS NOT NULL
  AND a.dt BETWEEN ADD_MONTHS(SYSDATE, -60) AND SYSDATE;
  
  -- Evaluating the status based on the average salary and total departures
  IF average_salary > 100000 AND total_departures >= 10 THEN
    RETURN 'CIP';
  ELSIF average_salary BETWEEN 50000 AND 100000 AND total_departures >= 5 THEN
    RETURN 'VIP';
  ELSE
    RETURN 'ORDINARY';
  END IF;
END;
/



-- Insertions --

INSERT INTO Citizen (ID, Name, DOB) VALUES (1, 'MAK', '01-JAN-1980');
INSERT INTO Citizen (ID, Name, DOB) VALUES (2, 'SAM', '05-MAR-1985');

INSERT INTO Salary (CID, Dt, Amount) VALUES (1, '01-JAN-2022', 175000);
INSERT INTO Salary (CID, Dt, Amount) VALUES (1, '01-JAN-2021', 80000);
INSERT INTO Salary (CID, Dt, Amount) VALUES (1, '01-JAN-2020', 85000);
INSERT INTO Salary (CID, Dt, Amount) VALUES (1, '01-JAN-2019', 90000);
INSERT INTO Salary (CID, Dt, Amount) VALUES (1, '01-JAN-2018', 95000);    /* the date goes back more than 5 years */
INSERT INTO Salary (CID, Dt, Amount) VALUES (2, '01-JAN-2022', 55000);
INSERT INTO Salary (CID, Dt, Amount) VALUES (2, '01-JAN-2021', 60000);
INSERT INTO Salary (CID, Dt, Amount) VALUES (2, '01-JAN-2020', 65000);
INSERT INTO Salary (CID, Dt, Amount) VALUES (2, '01-JAN-2019', 70000);
INSERT INTO Salary (CID, Dt, Amount) VALUES (2, '01-JAN-2018', 75000);

INSERT INTO AirportsLog (Dt, type, destination) VALUES (SYSDATE - 2, 'Departure', 'New York');
INSERT INTO AirportsLog (Dt, type, destination) VALUES (SYSDATE - 5, 'Arrival', 'London');
INSERT INTO AirportsLog (Dt, type, destination) VALUES (SYSDATE - 8, 'Departure', 'Tokyo');
INSERT INTO AirportsLog (Dt, type, destination) VALUES (SYSDATE - 7, 'Arrival', 'Paris');
INSERT INTO AirportsLog (Dt, type, destination) VALUES (SYSDATE - 5, 'Departure', 'New York');
INSERT INTO AirportsLog (Dt, type, destination) VALUES (SYSDATE - 6, 'Arrival', 'London');




SELECT cid, sum(s.amount)
FROM salary s
WHERE s.dt BETWEEN ADD_MONTHS(SYSDATE, -60) AND SYSDATE
group by cid;