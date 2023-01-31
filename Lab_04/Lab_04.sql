DROP table Transaction;
DROP table BALANCE;
DROP table ACCOUNT_;
DROP table AccountProperty;


CREATE TABLE AccountProperty
(
    ID number,
    name VARCHAR(255),
    ProfitRate number,
    GracePeriod number,
    CONSTRAINT PK_AccountProperty PRIMARY KEY(ID)
);

CREATE TABLE ACCOUNT_
(
    ID number,
    name VARCHAR(255),
    AccCode number,
    OpeningDate Date,
    LastDateInterest Date,
    CONSTRAINT PK_ACCOUNT PRIMARY KEY (ID),
    CONSTRAINT FK_ACCOUNT FOREIGN KEY (AccCode) REFERENCES AccountProperty (ID)
);

CREATE TABLE Balance
(
    AccNo number,
    PrincipalAmount number,
    ProfitAmount number,
    CONSTRAINT PK_BALANCE PRIMARY KEY (AccNo),
    CONSTRAINT FK_BALANCE FOREIGN KEY (AccNo) REFERENCES ACCOUNT_(ID)
);

Create Table Transaction 
(
    TID number,
    AccNo number,
    Amount number,
    TransactionDate Date,
    CONSTRAINT PK_TRANSACTION PRIMARY KEY (TID),
    CONSTRAINT FK_TRANSACTION FOREIGN KEY (AccNo) REFERENCES ACCOUNT_(ID)
);


insert into accountProperty values(2002, 'monthly', 2.8, 1);
insert into accountProperty values(3003, 'quaterly', 4.2, 4);
insert into accountProperty values(4004, 'biyearly', 6.8, 6);
insert into accountProperty values(5005, 'yearly', 8, 12);

insert into Account_ values(1, 'MAK', 3003, '31-DEC-2021' , '10-JAN-2023');

insert into Balance values(1,  10000, 0);

insert into Transaction values(1111, 1, 500, '02-FEB-2022');
insert into Transaction values(1112, 1, -2000, '02-FEB-2022');


SET SERVEROUTPUT ON SIZE 1000000

-- 1 

CREATE OR REPLACE FUNCTION get_current_balance (id number)
RETURN number
AS
    v_principal_balance number;
    v_change number;
    v_profit number;
Begin 

    select PrincipalAmount into v_principal_balance from BALANCE where AccNo = id;

    SELECT sum(Amount) as Change into v_change 
    from Transaction
    where AccNo = id
    Group by AccNo;

    SELECT ProfitAmount into v_profit from Balance where AccNo = id;

    return v_principal_balance+v_change+v_profit;
END;
/

SELECT get_current_balance(1) FROM DUAL;


select AccNo, PrincipalAmount from BALANCE;

SELECT AccNo, sum(Amount) as Change from Transaction
where AccNo = 1
Group by AccNo;

select accno, ProfitAmount from Balance;


-- 2

CREATE OR REPLACE FUNCTION calculate_profit (p_acc_id NUMBER)
RETURN VARCHAR2
AS
  v_profit_rate NUMBER;
  v_principal_amount NUMBER;
  v_profit NUMBER;
  v_balance_before NUMBER;
  v_balance_after NUMBER;
  v_days NUMBER;
  v_last_date_interest DATE;
BEGIN

  SELECT a.profitrate INTO v_profit_rate
  FROM AccountProperty a, ACCOUNT_ ac
  WHERE ac.AccCode = a.ID AND ac.ID = p_acc_id;

  SELECT b.PrincipalAmount INTO v_principal_amount
  FROM Balance b, ACCOUNT_ ac
  WHERE b.AccNo = ac.ID AND ac.ID = p_acc_id;

  SELECT ac.LastDateInterest INTO v_last_date_interest
  FROM ACCOUNT_ ac WHERE ac.ID = p_acc_id;

  v_days := TRUNC(SYSDATE) - TRUNC(v_last_date_interest);

  v_profit := v_profit_rate * v_principal_amount * floor(v_days / 365);

  v_balance_before := v_principal_amount;

  v_balance_after := v_principal_amount + v_profit;

  RETURN 'Profit: ' || v_profit || '   Before: ' || v_balance_before || '   After:' || v_balance_after;
END;
/

SELECT calculate_profit(1) FROM DUAL;



-- 3