
-- Generate account no. for customers

DROP TABLE CUSTOMERS CASCADE CONSTRAINTS;

CREATE TABLE customers 
(
  cid NUMBER,
  dob DATE NOT NULL,
  CONSTRAINT PK_CUSTOMERS PRIMARY KEY (cid)
);

Insert into customers VALUES(1, '01-JAN-2013');


drop sequence account_serial_seq;

CREATE SEQUENCE account_serial_seq
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 999999
NOCACHE;


CREATE OR REPLACE FUNCTION generate_account_no (p_branch_code VARCHAR2, p_acc_type VARCHAR2, p_cust_id NUMBER)
RETURN NUMBER
AS
  v_dob DATE;
  v_account_no NUMBER;
BEGIN
  -- Getting the DOB of the customer
  SELECT dob INTO v_dob
  FROM customers
  WHERE cid = p_cust_id;

  -- Generating the account number
  v_account_no := TO_NUMBER(p_acc_type || p_branch_code || TO_CHAR(v_dob, 'YYYYMMDD') || LPAD(DBMS_RANDOM.VALUE(1, 999999), 6, '0'));

  RETURN v_account_no;
END;
/


BEGIN
  DBMS_OUTPUT.PUT_LINE(generate_account_no( '123', '11', 1 ) );
END;
/
