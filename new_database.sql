DROP DATABASE IF EXISTS `faasos`;
CREATE DATABASE `faasos`; 
USE `faasos`;

-- TABLE DRIVER 

drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'2021-01-01'),
		(2,'2021-01-03'),
		(3,'2021-01-08'),
		(4,'2021-01-15');

-- TABLE INGREDIENT 

drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

-- TABLE ROLLS

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES 
(1	,'Non Veg Roll'),
(2	,'Veg Roll');

-- TABLE ROLL_RECIPES 

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES 
(1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

-- TABLE DRIVER_ORDER 

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES
(1,1,'2021-01-01 18:15:34','20km','32 minutes',''),
(2,1,'2021-01-01 19:10:54','20km','27 minutes',''),
(3,1,'2021-01-03 00:12:37','13.4km','20 mins','NaN'),
(4,2,'2021-01-03 13:53:03','23.4','40','NaN'),
(5,3,'2021-01-08 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'2021-01-08 21:30:45','25km','25mins',null),
(8,2,'2021-01-10 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'2021-01-11 18:50:20','10km','10minutes',null);

-- TABLE CUSTOMER_ORDER

drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values 
(1,101,1,'','','2021-01-01  18:05:02'),
(2,101,1,'','','2021-01-01 19:00:52'),
(3,102,1,'','','2021-01-02 23:51:23'),
(3,102,2,'','NaN','2021-01-02 23:51:23'),
(4,103,1,'4','','2021-01-03 13:23:46'),
(4,103,1,'4','','2021-01-03 13:23:46'),
(4,103,2,'4','','2021-01-03 13:23:46'),
(5,104,1,null,'1','2021-01-08 21:00:29'),
(6,101,2,null,null,'2021-01-08 21:03:13'),
(7,105,2,null,'1','2021-01-08 21:20:29'),
(8,102,1,null,null,'2021-01-09 23:54:33'),
(9,103,1,'4','1,5','2021-01-10 11:22:59'),
(10,104,1,null,null,'2021-01-11 18:34:49'),
(10,104,1,'2,6','1,4','2021-01-11 18:34:49');

-- DATA CLEANING AND UPDATING
-- TABLE CUSTOMER_ORDER AND DRIVER_ORDER
-- CREATING TWO NEW TABLES

drop table if exists customer_order_new;
CREATE TABLE customer_order_new AS
(
 SELECT order_id, customer_id,roll_id,
 CASE WHEN not_include_items IS NULL OR not_include_items = '' THEN '0' ELSE not_include_items END AS new_not_include_items,
 CASE WHEN extra_items_included IS NULL OR extra_items_included = '' OR extra_items_included = 'NaN' THEN '0' ELSE extra_items_included END AS new_extra_items_incuded,
 order_date
 FROM customer_orders
 UNION
 SELECT order_id, customer_id,roll_id,
 CASE WHEN not_include_items IS NULL OR not_include_items = '' THEN '0' ELSE not_include_items END AS new_not_include_items,
 CASE WHEN extra_items_included IS NULL OR extra_items_included = '' OR extra_items_included = 'NaN' THEN '0' ELSE extra_items_included END AS new_extra_items_incuded,
 order_date
 FROM customer_orders
);

-- In customer_order Table
-- Making all 'empty' and 'null' values to '0' in two columns (not_include_items,extra_items_included) 
-- Removing duplicates rows from data 

drop table if exists driver_order_new;
CREATE TABLE driver_order_new AS
( 
SELECT order_id,driver_id,pickup_time,distance,duration,
CASE WHEN cancellation IN ('Cancellation','Customer Cancellation') THEN '0' ELSE 1 END AS new_cancellation
FROM driver_order
);

-- In driver_order Table
-- Making all 'cancellation' to '0' 
 
 

