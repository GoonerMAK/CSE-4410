DROP TABLE loan_schemes CASCADE CONSTRAINTS;


-- Task A


CREATE TABLE loan_schemes 
(
  scheme_id NUMBER,
  scheme_name VARCHAR2(10),
  no_of_installments NUMBER,
  service_charge NUMBER,
  eligibility_amount NUMBER,
  CONSTRAINT PK_Loan_Scheme PRIMARY KEY (scheme_id)
);

INSERT INTO loan_schemes (scheme_id, scheme_name, no_of_installments, service_charge, eligibility_amount)
VALUES (1, 'S-A', 30, 5, 2000000);

INSERT INTO loan_schemes (scheme_id, scheme_name, no_of_installments, service_charge, eligibility_amount)
VALUES (2, 'S-B', 20, 10, 1000000);

INSERT INTO loan_schemes (scheme_id, scheme_name, no_of_installments, service_charge, eligibility_amount)
VALUES (3, 'S-C', 15, 15, 500000);


-- Task B

CREATE OR REPLACE FUNCTION assign_loan_scheme(p_customer_id NUMBER, p_total_transaction NUMBER)
RETURN VARCHAR2
IS
  v_scheme_name VARCHAR2(10);
BEGIN

  IF p_total_transaction > 2000000 THEN v_scheme_name := 'S-A';

  ELSIF p_total_transaction > 1000000 THEN v_scheme_name := 'S-B';

  ELSIF p_total_transaction > 500000 THEN v_scheme_name := 'S-C';

  ELSE v_scheme_name := 'Not eligible';

  END IF;

  RETURN v_scheme_name;

END;
/


-- Task C

CREATE OR REPLACE PROCEDURE schedule_loan(p_customer_id NUMBER, p_total_transaction NUMBER)
IS
  v_scheme_name VARCHAR2(10);
  v_installments NUMBER;
  v_due_date DATE;
BEGIN
  v_scheme_name := assign_loan_scheme(p_customer_id, p_total_transaction);

  IF v_scheme_name = 'S-A' THEN v_installments := 30;
  ELSIF v_scheme_name = 'S-B' THEN v_installments := 20;
  ELSIF v_scheme_name = 'S-C' THEN v_installments := 15;
  ELSE
    DBMS_OUTPUT.PUT_LINE('Customer is not eligible for a loan');
    RETURN;
  END IF;

  v_due_date := SYSDATE;
  FOR i IN 1..v_installments 
  LOOP
    v_due_date := v_due_date + 90;       -- 3 months interval (adding days to SYSDATE)
    DBMS_OUTPUT.PUT_LINE('Installment ' || i || ' is due on ' || v_due_date);
  END LOOP;

END;
/


DECLARE
BEGIN
  schedule_loan(3, 1100000);
END;
/