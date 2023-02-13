
-- Generate ID for citizen

drop sequence citizen_serial_seq;

CREATE SEQUENCE citizen_serial_seq
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 9999999
NOCACHE;


CREATE OR REPLACE FUNCTION generate_citizen_id(p_dob DATE, p_dv_code VARCHAR2)
RETURN VARCHAR2
IS
  v_dob VARCHAR2(8);
  v_serial VARCHAR2(7);
BEGIN
  v_dob := TO_CHAR(p_dob, 'YYYYMMDD');
  
  -- LPAD: left padding   
  v_serial := LPAD(citizen_serial_seq.NEXTVAL, 7, '0');

  RETURN p_dv_code || v_dob || '.' || v_serial;
END;
/


BEGIN
  DBMS_OUTPUT.PUT_LINE(generate_citizen_id( TO_DATE('04-JUN-2001'), 'DH' ));
END;
/
