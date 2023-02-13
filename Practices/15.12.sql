DROP table Accounts CASCADE CONSTRAINTS;
DROP table Transactions CASCADE CONSTRAINTS;
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

CREATE OR REPLACE FUNCTION EvaluateStatus (ID number)
RETURN VARCHAR
AS
  status VARCHAR(20);
  balance number;
BEGIN
  SELECT SUM(Current_Balance) Into balance 
  FROM Accounts
  WHERE CID = ID;

  IF balance > 100000 THEN status:='VIP';
  ELSIF balance BETWEEN 40000 AND 100000 THEN status:='IMPORTANT';
  ELSE status:='ORDINARY';
  END IF;

  RETURN Status;
END;
/


DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE(EvaluateStatus(1));
END;
/

    
-- Task B

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

-- Insert data into the Acc_type table
INSERT INTO Acc_type (ID, Name, Interest_Rate, GracePeriod)
VALUES (1, 'Savings Account', 3.0, 1);

INSERT INTO Acc_type (ID, Name, Interest_Rate, GracePeriod)
VALUES (2, 'Checking Account', 2.5, 2);

-- Insert data into the Customers table
INSERT INTO Customers (ID, Name, DOB, Address)
VALUES (1, 'MAK', '01-JAN-1980', '123 Main Street');

INSERT INTO Customers (ID, Name, DOB, Address)
VALUES (2, 'MAK', '15-MAR-1985', '456 Elm Street');

-- Insert data into the Accounts table
INSERT INTO Accounts (AccNo, CID, Acc_type, OpenDate, Current_Balance, LastDateInterestGiven)
VALUES (1, 1, 1, '01-JAN-2008', 1000.0, '01-JAN-2018');

INSERT INTO Accounts (AccNo, CID, Acc_type, OpenDate, Current_Balance, LastDateInterestGiven)
VALUES (2, 2, 2, '15-MAR-2005', 2000.0, '15-MAR-2022');

-- Insert data into the Transactions table
INSERT INTO Transactions (Dt, AccNo, Type, Amount)
VALUES (SYSDATE, 1, 'D', 100.0);

INSERT INTO Transactions (Dt, AccNo, Type, Amount)
VALUES (SYSDATE, 2, 'W', 200.0);
