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

insert into Account_ values('', 'AKASH', 3003, '31-DEC-2021' , '10-JAN-2023');
insert into Account_ values('2', 'SAM', 4004, '31-DEC-2020' , '10-JAN-2021');


insert into Transaction values(1111, '400420201231.SAM.000006', 500, '02-FEB-2022');

