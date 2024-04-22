--PIZZA SALES ANALYSIS

-- Retrieve the total number of orders placed.
select distinct count(order_id) as total_orders 
from orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


-- Identify the highest-priced pizza.
SELECT 
    pizzas.price, pizza_types.name
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.
select count(order_details.pizza_id), pizzas.size as most_common_size_ordered from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by count(order_details.pizza_id) desc ;


-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    SUM(order_details.quantity) AS quantity,
    pizzas.pizza_type_id
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.pizza_type_id
ORDER BY SUM(order_details.quantity) DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    SUM(order_details.quantity) AS total_quantity_ordered,
    order_details.pizza_id,
    pizza_types.name
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY order_details.pizza_id , pizza_types.name
ORDER BY total_quantity_ordered DESC ;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(orders.order_time) AS hour,
    COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(orders.order_time);


-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(pizza_types.name) AS count_of_pizza_types
FROM
    pizza_types
GROUP BY pizza_types.category


-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),0) as avg_pizzas_ordered_per_day
from
(SELECT 
    DATE(orders.order_date),
    SUM(order_details.quantity) AS quantity
FROM
    orders
        JOIN
    order_details ON order_details.order_id = orders.order_id
GROUP BY orders.order_date) as order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    SUM(order_details.quantity * pizzas.price) AS total_revenue,
    pizza_types.name
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY total_revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_revenue from 
(select orders.order_date , sum(order_details.quantity * pizzas.price) as revenue from order_details
join pizzas on order_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_details.order_id
group by  orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category ,name ,revenue from
(
select category, name , revenue, rank() over (partition by category order by revenue desc) as rn from
(select pizza_types.category, pizza_types.name , sum(order_details.quantity * pizzas.price) as revenue 
from pizza_types join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a
) as b
where rn <= 3;
