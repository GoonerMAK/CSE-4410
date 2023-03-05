SET SERVEROUTPUT ON SIZE 1000000

DROP TABLE customers CASCADE CONSTRAINTS;
DROP TABLE sims CASCADE CONSTRAINTS;
DROP TABLE plans CASCADE CONSTRAINTS;
DROP TABLE calls CASCADE CONSTRAINTS;


-- DDL

-- Create table for customer registration information
CREATE TABLE customers 
(
  customer_id NUMBER,
  name VARCHAR2(50) NOT NULL,
  dob DATE,
  address VARCHAR2(100),
  CONSTRAINT PK_CUSTOMER PRIMARY KEY (customer_id)
);

-- Create table for plan information
CREATE TABLE plans 
(
  plan_id NUMBER(10),
  plan_name VARCHAR2(50) NOT NULL,
  charge_per_min NUMBER(10, 2) NOT NULL,
  CONSTRAINT PK_plans PRIMARY KEY (plan_id)
);

-- Create table for SIM information
CREATE TABLE sims 
(
  sim_no NUMBER(10),
  plan_id NUMBER(10),
  customer_id NUMBER,
  CONSTRAINT PK_SIMS PRIMARY KEY (sim_no),  
  CONSTRAINT FK_plans FOREIGN KEY (plan_id) REFERENCES plans(plan_id), 
  CONSTRAINT FK_CUSTOMER FOREIGN KEY (customer_id) REFERENCES customers(customer_id)  
);


-- Create table for outgoing calls
CREATE TABLE calls 
(
  call_id number,
  sim_no NUMBER(10),
  call_begin DATE,
  call_end DATE,
  charge NUMBER(10, 2),
  CONSTRAINT PK_CALLS PRIMARY KEY (call_id),
  CONSTRAINT FK_sims FOREIGN KEY (sim_no) REFERENCES sims(sim_no)  
);



-- Call charge

CREATE OR REPLACE FUNCTION calculate_charge(p_sim_no NUMBER, p_call_begin DATE, p_call_end DATE)
RETURN NUMBER IS
  v_charge_per_min NUMBER(10, 2);
  v_duration_in_min NUMBER;
  v_total_charge NUMBER(10, 2);
BEGIN

  -- Get the charge per minute for the plan associated with the SIM
  SELECT charge_per_min INTO v_charge_per_min FROM plans p, sims s WHERE s.sim_no = p_sim_no AND s.plan_id = p.plan_id;
  
  v_duration_in_min := CEIL((p_call_end - p_call_begin) * 1440); 

  -- Calculate the total charge for the call based on the duration and charge per minute
  v_total_charge := v_duration_in_min * v_charge_per_min;
  
  RETURN v_total_charge;
END;
/


DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE('Call charge: ' || calculate_charge(1, TO_DATE('2023-02-28 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-02-28 10:05:00', 'YYYY-MM-DD HH24:MI:SS') ) );
END;
/


-- Trigger and Function

CREATE OR REPLACE FUNCTION generate_call_id (call_begin_date DATE) 
RETURN VARCHAR2 AS
  v_call_id NUMBER;
  v_prefix VARCHAR2(9);
BEGIN   
  v_prefix := TO_CHAR(call_begin_date, 'YYYYMMDD') || '.';

  -- Find the maximum existing call ID for this day and SIM (coalesce returns the first non-null expression in a list)
  SELECT COALESCE(MAX(call_id), 0) 
  INTO v_call_id FROM calls 
  WHERE TO_DATE(call_begin, 'YYYY-MM-DD') = TO_DATE(call_begin_date, 'YYYY-MM-DD');
  DBMS_OUTPUT.PUT_LINE( 'max calls: ' || v_call_id );

  -- Increment the numeric portion of the call ID
  v_call_id := v_call_id + 0.00000001;

  -- Combine the prefix and numeric portion to get the final CallID
  v_call_id := TO_NUMBER(v_prefix || TO_CHAR(v_call_id, 'FM00000000'));

  RETURN v_call_id;
END;
/

DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE( generate_call_id(TO_DATE('2023-01-01', 'YYYY-MM-DD')) );
END;
/

CREATE OR REPLACE TRIGGER call_id_trigger 
BEFORE INSERT ON CALLS 
FOR EACH ROW
BEGIN
  :NEW.call_id := generate_call_id(:NEW.call_begin);
END;
/


CREATE SEQUENCE call_id_seq
START WITH 1
INCREMENT BY 1
MINVALUE 1
NOCACHE;

CREATE OR REPLACE FUNCTION generate_call_id(call_begin_date DATE) 
RETURN VARCHAR2 IS
  call_id VARCHAR2(17);
BEGIN
  SELECT TO_CHAR(call_begin_date, 'YYYYMMDD') || '.' || LPAD(call_id_seq.NEXTVAL, 8, '0')
  INTO call_id
  FROM DUAL;
  
  RETURN call_id;
END;
/

DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE( generate_call_id(TO_DATE('2023-01-01', 'YYYY-MM-DD')) );
END;
/

CREATE OR REPLACE TRIGGER call_id_trigger
BEFORE INSERT ON calls
FOR EACH ROW
BEGIN
    :NEW.call_id := generate_call_id(:NEW.call_begin);
END;
/




-- Insert customer registration information
INSERT INTO customers (customer_id, name, dob, address) VALUES (1, 'MAK', TO_DATE('1990-01-01', 'YYYY-MM-DD'), 'Dhaka');
INSERT INTO customers (customer_id, name, dob, address) VALUES (2, 'SAM', TO_DATE('1995-05-10', 'YYYY-MM-DD'), 'Chittagong');

-- Insert plan information
INSERT INTO plans (plan_id, plan_name, charge_per_min) VALUES (1, 'Standard', 0.50);
INSERT INTO plans (plan_id, plan_name, charge_per_min) VALUES (2, 'Premium', 1.00);

-- Insert SIM information
INSERT INTO sims (sim_no, plan_id, customer_id) VALUES (01722270697, 1, 1);
INSERT INTO sims (sim_no, plan_id, customer_id) VALUES (01725419022, 2, 2);


-- Insert outgoing call information
INSERT INTO calls (call_id, sim_no, call_begin, call_end, charge) VALUES (1, 01722270697, TO_DATE('2022-01-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2022-01-01 10:05:00', 'YYYY-MM-DD HH24:MI:SS'), 0);
INSERT INTO calls (call_id, sim_no, call_begin, call_end, charge) VALUES (2, 01725419022, TO_DATE('2022-01-01 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2022-01-01 11:02:05', 'YYYY-MM-DD HH24:MI:SS'), 0);




-- Shcolarship Distribution

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