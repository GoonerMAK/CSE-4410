
-- a --
select count(*), f_name from franchise_customer_list
Group by f_name;


-- b --
select avg(menu_rating),  menu_name
from rating
group by menu_name;


-- c --
select ROWNUM as times_ordered, menu_name
from(select count(order_id), menu_name
from orders
group by menu_name
order by count(order_id) DESC)
where ROWNUM<=5;


-- d --
SELECT c_id from 
(select menu_name from
 (select count(menu_name) as times, menu_name from menu
   group by menu_name)
where times>=2), preference
where menu_name=prefered_food;


-- e --
select Distinct customer.c_id 
from Orders, customer
where customer.c_id
    not in (select c_id from orders);