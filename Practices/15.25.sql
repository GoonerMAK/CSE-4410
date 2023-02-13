
-- Task A

/* In this diagram, there are three tables:

Account: This table stores information about the accounts, including the account number, 
type (single, joint, or business), and date of opening.

Account Holder: This table stores information about the account holders,
including the account number and the person's name. For joint accounts, 
there will be multiple entries with the same account number but different names.

Transaction: This table stores information about the daily transactions,
including the transaction ID (generated using the format TPYYYYDDMMHHMMSS),\
the account number, the transaction amount, and the date and time of the transaction. 

*/

-- The Restrictions

ALTER TABLE Transaction ADD CONSTRAINT chk_transaction_limit CHECK (amount <= 100000);

ALTER TABLE Transaction
ADD CONSTRAINT chk_monthly_limit CHECK 
(
  (SELECT SUM(amount) FROM Transaction
   WHERE account_number = Transaction.account_number
   AND to_char(transaction_date, 'YYYY-MM') = to_char(Transaction.transaction_date, 'YYYY-MM')
  ) <= 500000
);



-- Task B

DECLARE
  v_total_balance       NUMBER;
  v_tax       NUMBER;
  v_tax_rate  NUMBER;
BEGIN
  -- Get the total salary paid at the end of the year
  v_total_balance := '&v_total_balance';
 
  -- Calculate the tax based on the Total Salary Paid
  IF v_total_balance < 100000 THEN v_tax_rate := 0;

  ELSIF v_total_balance >= 100000 AND v_total_balance < 400000 THEN v_tax_rate := 0.05;

  ELSIF v_total_balance >= 400000 AND v_total_balance < 1000000 THEN v_tax_rate := 0.1;

  ELSE v_tax_rate := 0.2;

  END IF;

  -- Calculate the tax amount
  v_tax := v_total_balance * v_tax_rate;

  -- Display the tax amount
  DBMS_OUTPUT.PUT_LINE('Tax Amount: ' || v_tax);
END;
/

