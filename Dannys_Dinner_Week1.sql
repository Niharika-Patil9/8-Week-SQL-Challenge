/* --------------------
   Case Study Questions
   --------------------*/

select * from sales;
-- 1. What is the total amount each customer spent at the restaurant?

SELECT
  	sales.customer_id ,
    sum(price) as Total
FROM sales JOIN menu 
on sales.product_id = menu.product_id
group by sales.customer_id
order by Total desc;

-- 2. How many days has each customer visited the restaurant?

select customer_id , count(distinct(order_date)) from sales 
group by sales.customer_id;

-- 3. What was the first item from the menu purchased by each customer?
select customer_id, product_id, product_name from 
(select sales.customer_id, menu.product_id, sales.order_date, menu.product_name, 
row_number() over(partition by sales.customer_id order by order_date) as rn
from sales join menu on sales.product_id = menu.product_id) as A
where rn = 1; 

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select s.customer_id, count(s.product_id) as Most_Purchased, s.product_id	,m.product_name from sales s
JOIN menu m on
s.product_id = m.product_id
group by (s.product_id)
order by count(s.product_id) desc
LIMIT 1;


-- 5. Which item was the most popular for each customer?
select customer_id, product_name as Most_Popular_Product, Count_Order  from 
(select 
s.customer_id , 
m.product_name, 
count(m.product_name) as Count_Order, 
m.product_id,
row_number() over (partition by s.customer_id order by count(m.product_name) desc) as row_num
from sales s JOIN menu m 
on s.product_id = m.product_id
group by customer_id ,product_name) as A
where row_num = 1;



-- 6. Which item was purchased first by the customer after they became a member?
Select customer_id,  product_id, product_name, join_date, order_date from 
(select sales.customer_id, sales.order_date ,members.join_date,  menu.product_name ,  menu.product_id,
rank() over (partition by customer_id order by order_date asc) as row_num
from sales JOIN members on sales.customer_id = members.customer_id
JOIN menu on  menu.product_id = sales.product_id
where sales.order_date >= members.join_date ) as A 
where row_num = 1;



-- 7. Which item was purchased just before the customer became a member?
Select customer_id,  product_id, product_name, order_date, join_date from
(select sales.customer_id , menu.product_id, menu.product_name , sales.order_date , members.join_date,
row_number() over (partition by customer_id order by order_date asc) as row_num
from sales join menu on sales.product_id = menu.product_id 
join members on members.customer_id = sales.customer_id
where sales.order_date < members.join_date) as A
where row_num = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
  sales.customer_id, 
  COUNT(sales.product_id) AS total_items, 
  SUM(menu.price) AS amount_spent
FROM sales
JOIN members
  ON sales.customer_id = members.customer_id
  AND sales.order_date < members.join_date
JOIN menu
  ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select customer_id,
SUM(CASE 
    WHEN product_name = 'sushi' then price * 10 * 2
    ELSE price * 10
   END ) as Points 
   from menu 
   JOIN sales on
   sales.product_id = menu.product_id
   group by sales.customer_id;
   


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?


SELECT
  m.customer_id,
  SUM(CASE
    WHEN s.order_date <= DATE_ADD(m.join_date, INTERVAL 1 WEEK) THEN 2 * menu.price
    ELSE menu.price * 10
  END) AS total_points
FROM
  members m
  JOIN sales s ON m.customer_id = s.customer_id
  JOIN menu ON s.product_id = menu.product_id
WHERE
  s.order_date <= '2021-01-31'
GROUP BY
  m.customer_id;




