drop table orders;
drop table rating;
drop table menu;
drop table franchise;
drop table customer;
drop table franchise_customer;



create table franchise
(
    f_name varchar2(50),
    CONSTRAINT PK_FRANCHISE PRIMARY KEY (f_name)
);


create table customer
(
    c_id varchar2(50),
    CONSTRAINT PK_CUSTOMER PRIMARY KEY (c_id)
);


create table franchise_customer_list
(
    f_name varchar2(50),
    c_id varchar2(50),
    CONSTRAINT PK_FRANCHISE_CUSTOMER_LIST PRIMARY KEY (f_name, c_id)
);


create table menu
(
    f_name varchar2(50),
    menu_name varchar2(50),
    CONSTRAINT FK_MENU FOREIGN KEY (f_name) REFERENCES franchise(f_name),
    CONSTRAINT PK_MENU PRIMARY KEY (f_name, menu_name)
);


create table Rating
(
    f_name varchar2(50),
    menu_name varchar2(50),
    menu_rating number,
    c_id varchar2(50),
    CONSTRAINT FK_RATING FOREIGN KEY (f_name, menu_name) REFERENCES menu(f_name, menu_name),
    CONSTRAINT PK_RATING PRIMARY KEY (c_id, f_name, menu_name)
);


create table orders
(
    order_id varchar2(50),
    c_id varchar2(50),
    f_name varchar2(50),
    menu_name varchar2(50),
    CONSTRAINT FK_ORDER_CUSTOMER FOREIGN KEY (c_id) REFERENCES customer(c_id),
    CONSTRAINT FK_ORDER_MENU FOREIGN KEY (f_name, menu_name) REFERENCES menu(f_name, menu_name),
    CONSTRAINT PK_ORDER PRIMARY KEY (order_id)
);


create table preference
(
    c_id varchar2(50),
    prefered_food varchar2(50),
    CONSTRAINT PK_PREFERENCE FOREIGN KEY (c_id) REFERENCES customer(c_id)
);






