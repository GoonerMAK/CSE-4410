
SET SERVEROUTPUT ON SIZE 1000000

-- 1 : Calculating the current balance from the transactions

CREATE OR REPLACE FUNCTION get_current_balance (id number)
RETURN number
AS
    v_principal_balance number;
    v_change number;
    v_profit number;
Begin 

  select PrincipalAmount into v_principal_balance from BALANCE where AccNo = id;

  /* A transaction can be negative (debit) or positive (credit) */
  SELECT sum(Amount) as Change   /* That's why we're summing the amount to get the net change */
  into v_change    
  from Transaction 
  where AccNo = id
  Group by AccNo;

  return v_principal_balance + v_change;
END;
/

SELECT get_current_balance(1) FROM DUAL;
SELECT get_current_balance(2) FROM DUAL;

DECLARE
    ID number;
BEGIN
    ID := '&ID';
  DBMS_OUTPUT.PUT_LINE(get_current_balance(ID)) ;
END;
/


select AccNo, PrincipalAmount from BALANCE;

SELECT AccNo, sum(Amount) as Change from Transaction
where AccNo = 1
Group by AccNo;

SELECT accno, ProfitAmount from Balance;


-- 2 : Calculating the profit based on profit rate, grace period and amount

CREATE OR REPLACE FUNCTION calculate_profit(p_acc_id NUMBER)
RETURN VARCHAR2
AS
  v_profit_rate NUMBER;
  v_principal_amount NUMBER;
  v_profit NUMBER(12,3);
  v_balance_before NUMBER(12,3);
  v_balance_after NUMBER(12,3);
  v_days NUMBER;
  v_last_date_interest DATE;
  v_grace_period NUMBER;
  v_times_balance_increase NUMBER;
BEGIN
 
  SELECT (a.profitrate/100) INTO v_profit_rate  /* Fetching Profit Rate */
  FROM AccountProperty a, ACCOUNT_ ac
  WHERE ac.AccCode = a.ID AND ac.ID = p_acc_id;

  SELECT b.PrincipalAmount INTO v_principal_amount  /* Fetching Principal Amount */
  FROM Balance b, ACCOUNT_ ac
  WHERE b.AccNo = ac.ID AND ac.ID = p_acc_id;

  SELECT ac.LastDateInterest INTO v_last_date_interest  /* Fetching Last Date Inerest */
  FROM ACCOUNT_ ac WHERE ac.ID = p_acc_id;

  SELECT a.GracePeriod into v_grace_period   /* Fetching Grace Period */
  FROM AccountProperty a, ACCOUNT_ ac
  where a.ID = ac.AccCode AND ac.ID = p_acc_id;

  v_days := TRUNC(SYSDATE) - TRUNC(v_last_date_interest);  /* Difference Between the Dates in days */

  /* After every grace period, Profit amount increases. Here we're calculating the # of increases */
  v_times_balance_increase := floor((floor(v_days / 30))/v_grace_period);

  v_balance_after := v_principal_amount;

  FOR i in 1..v_times_balance_increase
  LOOP                         /* The initial balance increases after every grace peiod */
    v_balance_after := v_balance_after + v_profit_rate*v_balance_after;
  END LOOP;

  v_balance_before := v_principal_amount;

  v_profit := v_balance_after - v_balance_before;

  RETURN 'Profit: ' || v_profit || '   Before: ' || v_balance_before || '   After:' || v_balance_after;
END;
/

SELECT calculate_profit(1) FROM DUAL;
SELECT calculate_profit(2) FROM DUAL;

DECLARE
    ID number;
BEGIN
    ID := '&ID';
  DBMS_OUTPUT.PUT_LINE(calculate_profit(ID)) ;
END;
/


SELECT floor((floor((TRUNC(SYSDATE) - TRUNC(ACCOUNT_.LastDateInterest))/30))/GracePeriod) 
from Account_, AccountProperty 
where Account_.AccCode = AccountProperty.ID AND Account_.AccCode = 4004;


BEGIN
    DBMS_OUTPUT.PUT_LINE(TRUNC(SYSDATE) - TRUNC(TO_DATE('01-SEP-15'))) ;
END;
/


-- 3 : Calculate profit for all accounts

CREATE OR REPLACE PROCEDURE calculate_profit_all_accounts
AS
    v_acc_id number;
    output varchar2(1000);
    profit number(12,3);

    cursor get_accounts is
    SELECT ac.ID FROM Account_ ac;

BEGIN
  OPEN get_accounts;
  LOOP
    FETCH get_accounts into v_acc_id;   /* Fetching every account from ACCOUNT_ */
    EXIT WHEN get_accounts%notfound;  
    output := calculate_profit(v_acc_id);   /* getting all the relevant info */
    DBMS_OUTPUT.PUT_LINE('Account ID: ' || v_acc_id || '   ' || output );
    
    /* TRIM() function is helping us extract the profit from the output */
    SELECT TRIM( ':' FROM REGEXP_SUBSTR( output, '\:[^B]+' )) INTO profit FROM DUAL;
    
    /* Updating the profit amount */
    UPDATE BALANCE SET ProfitAmount = profit WHERE AccNo =  v_acc_id;

    /* Updating the Principal amount (which will increase because of profit) */
    UPDATE BALANCE SET PrincipalAmount = PrincipalAmount + profit WHERE AccNo =  v_acc_id;
    
    /* Updating Last Date of Interest to SYSDATE */
    UPDATE ACCOUNT_ SET LastDateInterest = SYSDATE WHERE ID = v_acc_id;

  END LOOP;
  CLOSE get_accounts;

END;
/       

BEGIN
    calculate_profit_all_accounts();
END;
/

