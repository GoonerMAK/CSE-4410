DROP table Transaction;
DROP table BALANCE;
DROP table ACCOUNT_;
DROP table AccountProperty;


CREATE TABLE AccountProperty
(
    ID number,
    name VARCHAR(255),
    ProfitRate number,
    GreacePeriod number,
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

