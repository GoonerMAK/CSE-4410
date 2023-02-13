
-- Generate ID for Students


CREATE OR REPLACE FUNCTION generate_student_id(p_enroll_date DATE, p_dept_code VARCHAR2, p_program_code VARCHAR2)
RETURN NUMBER
AS
  v_student_id NUMBER;
BEGIN
  -- Generate the student ID
  v_student_id := TO_NUMBER(TO_CHAR(p_enroll_date, 'YY') || p_dept_code || p_program_code || LPAD(DBMS_RANDOM.VALUE(1, 99), 2, '0') );

  -- Return the generated student ID
  RETURN v_student_id;
END;
/

BEGIN
  DBMS_OUTPUT.PUT_LINE(generate_student_id( '01-JUN-2020' , '4', '2') );
END;
/
