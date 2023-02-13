
-- Task A

CREATE OR REPLACE FUNCTION calculate_salary(p_scale VARCHAR2, p_basic NUMBER, p_days_worked NUMBER)
RETURN NUMBER
IS
  v_housing NUMBER;
  v_transport NUMBER;
  v_total_salary NUMBER(12,3);
BEGIN
  IF p_scale = 'S1' THEN
    v_housing := p_basic * 0.10;
    v_transport := p_basic * 0.15;
  ELSIF p_scale = 'S2' THEN
    v_housing := p_basic * 0.20;
    v_transport := p_basic * 0.10;
  ELSIF p_scale = 'S3' THEN
    v_housing := p_basic * 0.30;
    v_transport := p_basic * 0.05;
  ELSE
    RETURN 0;
  END IF;

  v_total_salary := (p_basic + v_housing + v_transport) * (p_days_worked / 22);   -- salary being calculated day wise (8 weekends)

  RETURN v_total_salary;
END;
/

BEGIN
  DBMS_OUTPUT.PUT_LINE(calculate_salary('S1', 1000, 23));
END;
/


CREATE OR REPLACE TRIGGER salary_trigger
AFTER INSERT OR UPDATE OF scale, basic_salary, days_worked
ON employees
FOR EACH ROW
DECLARE
  v_salary NUMBER;
BEGIN
  v_salary := calculate_salary(:new.scale, :new.basic_salary, :new.days_worked);

  :new.monthly_salary := v_salary;
END;
/

-- INSERT INTO TABLE_NAME (TIMESTAMP_VALUE) VALUES (TO_TIMESTAMP('2014-07-02 06:14:00.742000000', 'YYYY-MM-DD HH24:MI:SS.FF'));



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
