DROP table Transaction;
DROP table BALANCE;
DROP table ACCOUNT_;
DROP table AccountProperty;

drop sequence account_serial_seq;


SET SERVEROUTPUT ON SIZE 1000000

-- 1 : Generating an account_id according to a structure

CREATE SEQUENCE account_serial_seq
START WITH 1
INCREMENT BY 1
MINVALUE 1
NOCACHE;

CREATE OR REPLACE FUNCTION generate_account_id (name VARCHAR2, acc_code NUMBER, opening_date DATE)
RETURN VARCHAR2
AS
  n_serial_no NUMBER;
  n_name VARCHAR2(3);
BEGIN
  n_serial_no := account_serial_seq.NEXTVAL;
  n_name := SUBSTR(name, 1, 3);

  /* adding left padding */
  RETURN LPAD(TO_CHAR(acc_code), 4, '0')
      || TO_CHAR(opening_date, 'YYYYMMDD')
      || '.'
      || n_name
      || '.'
      || LPAD(TO_CHAR(n_serial_no), 6, '0');
END;
/

BEGIN
  DBMS_OUTPUT.PUT_LINE(generate_account_id( 'MAK', 4004, TO_DATE('31-DEC-2021') ) );
END;
/



-- 2 : Making neccessary alterations (for newly generated Acoount ID)


ALTER TABLE Balance DROP CONSTRAINT FK_BALANCE;

ALTER TABLE Balance MODIFY AccNo VARCHAR2(23);

ALTER TABLE Transaction DROP CONSTRAINT FK_TRANSACTION;

ALTER TABLE Transaction MODIFY AccNo VARCHAR2(23);

ALTER TABLE ACCOUNT_ MODIFY ID VARCHAR2(23);

ALTER TABLE Balance
ADD CONSTRAINT FK_BALANCE FOREIGN KEY (AccNo) REFERENCES ACCOUNT_(ID);

ALTER TABLE Transaction
ADD CONSTRAINT FK_TRANSACTION FOREIGN KEY (AccNo) REFERENCES ACCOUNT_(ID);



-- 3 : Automate the Account_ID while inserting new accounts

CREATE OR REPLACE TRIGGER assign_account_id
BEFORE INSERT ON ACCOUNT_
FOR EACH ROW
BEGIN
    :NEW.ID := generate_account_id(:NEW.NAME, :NEW.AccCode, :NEW.OpeningDate);
END;
/


-- 4 : Automatically insert a new entry into the Balance table when an account is created

CREATE OR REPLACE TRIGGER insert_balance_entry
AFTER INSERT ON ACCOUNT_
FOR EACH ROW
DECLARE
BEGIN
    INSERT INTO Balance (AccNo, PrincipalAmount, ProfitAmount)
    VALUES (:NEW.ID, 5000, 0);
END;
/


-- 5 : Updating the prinipal amount when there's a transaction

CREATE OR REPLACE TRIGGER update_balance
AFTER INSERT ON Transaction
FOR EACH ROW
DECLARE
    previous_principal_amount NUMBER(12, 3);
BEGIN
    SELECT PrincipalAmount INTO previous_principal_amount
    FROM Balance
    WHERE AccNo = :NEW.AccNo;

    UPDATE Balance
    SET PrincipalAmount = previous_principal_amount + :NEW.Amount
    WHERE AccNo = :NEW.AccNo;
END;
/