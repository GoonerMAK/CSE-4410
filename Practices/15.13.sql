DROP table Accounts CASCADE CONSTRAINTS;
DROP table Transactions CASCADE CONSTRAINTS;
DROP TABLE Defaulters CASCADE CONSTRAINTS;
DROP table Customers CASCADE CONSTRAINTS; 
DROP table Acc_type CASCADE CONSTRAINTS;

CREATE TABLE Acc_type 
(
  ID NUMBER,
  Name VARCHAR(255),
  Interest_Rate FLOAT,
  GracePeriod number,
  CONSTRAINT PK_Acc_type PRIMARY KEY(ID)
);

CREATE TABLE Customers 
(
  ID number,
  Name VARCHAR(255),
  DOB DATE,
  Address VARCHAR(255),
  CONSTRAINT PK_Customers PRIMARY KEY(ID)
);


CREATE TABLE Defaulters 
(
  CID number,
  DT DATE, 
  Type VARCHAR(10),
  CONSTRAINT PK_Defaulters PRIMARY KEY(CID, DT, Type),
  CONSTRAINT FK_Defaulters FOREIGN KEY (CID) REFERENCES Customers(ID)
);


CREATE TABLE Accounts 
(
  AccNo number,
  CID number,
  Acc_type number,
  OpenDate DATE,
  Current_Balance FLOAT,
  LastDateInterestGiven DATE,
  CONSTRAINT PK_Accounts PRIMARY KEY(AccNo),
  CONSTRAINT FK_Accounts_customers FOREIGN KEY (CID) REFERENCES Customers(ID),
  CONSTRAINT FK_Accounts_acc_type FOREIGN KEY (Acc_type) REFERENCES Acc_type(ID)
);


CREATE TABLE Transactions 
(
  Dt DATE,
  AccNo number,
  Type VARCHAR(10),
  Amount FLOAT,
  CONSTRAINT PK_Transactions PRIMARY KEY(DT, AccNo),
  CONSTRAINT FK_Transactions FOREIGN KEY (AccNo) REFERENCES Accounts(AccNo)
);


-- Task A  

CREATE OR REPLACE FUNCTION get_customer_status (p_cid IN NUMBER)
RETURN VARCHAR2
IS
  v_current_balance FLOAT;
  v_major_count NUMBER;
  v_minor_count NUMBER;
BEGIN
  -- Get the customer's current balance
  SELECT Current_Balance
  INTO v_current_balance
  FROM Accounts
  WHERE CID = p_cid;
  
  -- Get the count of major and minor allegations for the customer
  SELECT COUNT(CASE WHEN Type = 'major' THEN 1 END) AS major_count,
         COUNT(CASE WHEN Type = 'minor' THEN 1 END) AS minor_count
  INTO v_major_count, v_minor_count
  FROM Defaulters
  WHERE CID = p_cid;
  
  -- Evaluate the status based on the algorithm described
  IF v_current_balance >= 200000 AND v_major_count = 0 THEN
    RETURN 'VIP';
  ELSIF v_current_balance >= 40000 AND v_current_balance < 200000 AND v_major_count = 0 THEN
    RETURN 'IMPORTANT';
  ELSIF v_current_balance >= 10000 AND v_current_balance < 40000 AND v_major_count = 1 THEN
    RETURN 'ORDINARY';
  ELSIF v_major_count >= 3 AND v_minor_count >= 5 THEN
    RETURN 'CRIMINAL';
  ELSE
    RETURN 'UNKNOWN';
  END IF;
END;
/

DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE(get_customer_status(1));
END;
/


-- Task A (With Cursors)

CREATE OR REPLACE FUNCTION get_customer_status(p_cid IN NUMBER)
RETURN VARCHAR2
IS
  v_current_balance FLOAT;
  v_major_count NUMBER := 0;
  v_minor_count NUMBER := 0;
  v_status VARCHAR2(20) := 'UNKNOWN';

  cursor c_defaulters is
  SELECT Type
  FROM Defaulters
  WHERE CID = p_cid;

BEGIN
  -- Get the customer's current balance
  SELECT Current_Balance
  INTO v_current_balance
  FROM Accounts
  WHERE CID = p_cid;

  -- Loop through the customer's allegations to get the count of major and minor allegations
  FOR defaulters in c_defaulters LOOP
    IF defaulters.Type = 'major' THEN
      v_major_count := v_major_count + 1;
    ELSIF defaulters.Type = 'minor' THEN
      v_minor_count := v_minor_count + 1;
    END IF;
  END LOOP;

  -- Evaluate the status based on the algorithm described
  IF v_current_balance >= 200000 AND v_major_count = 0 THEN
    v_status := 'VIP';
  ELSIF v_current_balance >= 40000 AND v_current_balance < 200000 AND v_major_count = 0 THEN
    v_status := 'IMPORTANT';
  ELSIF v_current_balance >= 10000 AND v_current_balance < 40000 AND v_major_count = 1 THEN
    v_status := 'ORDINARY';
  ELSIF v_major_count >= 3 AND v_minor_count >= 5 THEN
    v_status := 'CRIMINAL';
  END IF;

  RETURN v_status;
END;
/
    

-- Task B  (copied and pasted from 15.12's task B)

CREATE OR REPLACE PROCEDURE update_balance (p_accno IN Accounts.AccNo%TYPE)
AS
  v_interest FLOAT;
  v_last_interest_given DATE;
  v_interest_rate FLOAT;
  v_months_since_last_interest NUMBER;
BEGIN
  SELECT Current_Balance, LastDateInterestGiven, Interest_Rate
  INTO v_interest, v_last_interest_given, v_interest_rate
  FROM Accounts a
  JOIN Acc_type t ON a.Acc_type = t.ID
  WHERE a.AccNo = p_accno;

  v_months_since_last_interest := MONTHS_BETWEEN(SYSDATE, v_last_interest_given);  /* gets the months number between the dates */

  IF v_months_since_last_interest BETWEEN 1 AND 3 THEN
    v_interest := v_interest * (1 + (v_interest_rate / 100) * v_months_since_last_interest);
  ELSIF v_months_since_last_interest BETWEEN 3 AND 6 THEN
    v_interest := v_interest * (1 + (v_interest_rate / 100) * 3);
  END IF;

  UPDATE Accounts
  SET Current_Balance = v_interest, LastDateInterestGiven = SYSDATE
  WHERE AccNo = p_accno;
END;
/



-- Insertions --

