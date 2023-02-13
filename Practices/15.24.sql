
-- Task A

DECLARE
  v_basic   NUMBER;
  v_salary  NUMBER;
  v_scale   VARCHAR2(2);
  v_timestamp VARCHAR2(17);
BEGIN
  -- Get the scale value from the user
  v_scale := '&scale';

  -- Calculate the basic salary based on the scale value
  IF v_scale = 'S1' THEN
     v_basic := 10000;
  ELSIF v_scale = 'S2' THEN
     v_basic := 20000;
  ELSIF v_scale = 'S3' THEN
     v_basic := 30000;
  END IF;

  -- Calculate the total monthly salary
  v_salary := v_basic + (v_basic * 0.4) + (v_basic * 0.1);

  -- Get the current transaction timestamp
  SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHHMMSS') INTO v_timestamp FROM DUAL;

  -- Display the monthly salary and transaction timestamp
  DBMS_OUTPUT.PUT_LINE('Monthly Salary: ' || v_salary);
  DBMS_OUTPUT.PUT_LINE('Transaction Timestamp: ' || 'TP' || v_timestamp);
END;
/



-- Task B

DECLARE
  v_tsp       NUMBER;
  v_tax       NUMBER;
  v_tax_rate  NUMBER;
BEGIN
  -- Get the total salary paid at the end of the year
  v_tsp := '&tsp';
 
  -- Calculate the tax based on the Total Salary Paid
  IF v_tsp < 100000 THEN v_tax_rate := 0;

  ELSIF v_tsp >= 100000 AND v_tsp < 400000 THEN v_tax_rate := 0.05;

  ELSIF v_tsp >= 400000 AND v_tsp < 1000000 THEN v_tax_rate := 0.1;

  ELSE v_tax_rate := 0.2;

  END IF;

  -- Calculate the tax amount
  v_tax := v_tsp * v_tax_rate;

  -- Display the tax amount
  DBMS_OUTPUT.PUT_LINE('Tax Amount: ' || v_tax);
END;
/
