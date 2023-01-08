

INSERT INTO franchise values ('Dominoes');
INSERT INTO franchise values ('Pizza Hut');
INSERT INTO franchise values ('Pizza Inn');


INSERT INTO customer values ('1');
INSERT INTO customer values ('2');
INSERT INTO customer values ('3');
INSERT INTO customer values ('4');
INSERT INTO customer values ('5');


INSERT INTO franchise_customer_list values ('Dominoes', '1');
INSERT INTO franchise_customer_list values ('Dominoes', '2');
INSERT INTO franchise_customer_list values ('Dominoes', '3');
INSERT INTO franchise_customer_list values ('Dominoes', '4');
INSERT INTO franchise_customer_list values ('Pizza Hut', '1');
INSERT INTO franchise_customer_list values ('Pizza Hut', '4');
INSERT INTO franchise_customer_list values ('Pizza Inn', '1');
INSERT INTO franchise_customer_list values ('Pizza Inn', '5');



INSERT INTO menu values ('Dominoes', 'dessert');
INSERT INTO menu values ('Pizza Hut', 'fries');
INSERT INTO menu values ('Dominoes', 'fries');
INSERT INTO menu values ('Pizza Inn', 'hot dog');



INSERT INTO rating values ('Dominoes', 'dessert', '8', '1');
INSERT INTO rating values ('Dominoes', 'fries', '10', '2');
INSERT INTO rating values ('Dominoes', 'fries', '7', '3');
INSERT INTO rating values ('Dominoes', 'fries', '9', '4');
INSERT INTO rating values ('Pizza Hut', 'fries', '3', '1');
INSERT INTO rating values ('Pizza Hut', 'fries', '5', '4');
INSERT INTO rating values ('Pizza Inn', 'hot dog', '10', '1');
INSERT INTO rating values ('Pizza Inn', 'hot dog', '9', '5');




INSERT INTO Orders values ('1', '1', 'Dominoes', 'dessert');
INSERT INTO Orders values ('2', '4', 'Pizza Hut', 'fries');
INSERT INTO Orders values ('3', '3', 'Dominoes', 'fries');
INSERT INTO Orders values ('4', '1', 'Pizza Inn', 'hot dog'); 


INSERT INTO preference values ('1', 'fries');
INSERT INTO preference values ('2','fries');
INSERT INTO preference values ('3', 'hot dog'); 
