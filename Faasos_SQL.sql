-- /TOPICS/
-- A) ROLL METRICS
-- B) DRIVER AND CUSTOMER EXPERIENCE 
-- C) INGREDIENT OPTIMIZATION
-- D) PRICING AND RATING

-- 1) HOW MANY ROLLS WERE ORDERED? ANS:-13

SELECT COUNT(roll_id) AS no_of_orders 
FROM customer_order_new;

-- 2) HOW MANY UNIQUE CUSTOMERS WERE MADE ANS:-5

SELECT COUNT(*) AS Unique_Customers
FROM (SELECT customer_id FROM customer_order_new
	  GROUP BY customer_id ) AS no_of_customer;
      
--
-- --Another Method 
--  

SELECT COUNT(DISTINCT customer_id) 
FROM customer_order_new;

-- 3) HOW MANY SUCCESSFUL ORDERS WERE DELIVERD BY EACH DRIVER? ANS:- 4,3,1   

SELECT driver_id,COUNT(order_id) AS Delivered_Orders 
FROM (SELECT * FROM driver_order_new
	  WHERE new_cancellation != 0  ) a
GROUP BY driver_id;


-- 4) HOW MANY EACH TYPE OF ROLL WERE DELIVERED? ANS:- 8(Non-Veg),3(VEG)

SELECT roll_name,COUNT(a.roll_id) AS no_of_rolls
FROM (SELECT order_id,rolls.roll_id,roll_name FROM customer_order_new con
	  JOIN rolls 
		ON rolls.roll_id = con.roll_id
	  WHERE order_id IN ( SELECT order_id FROM driver_order_new
					WHERE new_cancellation <> 0 ) ) a  
GROUP BY roll_name;


-- EXPLANATION
-- firstly removing all cancellation order
-- joining with rolls table to get veg and non-veg 
-- then grouping roll_name and counting roll_id 


-- 5) HOW MANY VEG AND NON-VEG ROLLS WERE ORDERED BY EACH CUSTOMER?

SELECT customer_id,roll_name,COUNT(rolls.roll_id) AS no_of_rolls
FROM (SELECT * FROM customer_order_new
	  WHERE order_id IN ( SELECT order_id FROM driver_order_new
						  WHERE new_cancellation <> 0 )) AS customer_roll , rolls
WHERE customer_roll.roll_id = rolls.roll_id
GROUP BY customer_id,roll_name;

-- EXPLANATION
-- firstly excluding all cancelation order
-- then joining with rolls on basis of roll_id
-- then grouping them on roll_name,customer_id and count the no of rolls  


-- 6) WHAT WAS THE MAXIXMAM NUMBER OF ROLLS DELIVERED IN SINGLE ORDER? ANS:- 2

SELECT MAX(no_of_rolls) FROM (
 SELECT order_id,COUNT(roll_id) AS no_of_rolls FROM (
  SELECT * FROM customer_order_new 
    WHERE order_id IN ( SELECT order_id FROM driver_order_new
					    WHERE new_cancellation <> 0 ))a
 GROUP BY order_id) b;

-- EXPLANATION
-- removing cancelation order
-- group by order_id and count roll_id 
-- then max of roll_id 


-- 7) FOR EACH CUSTOMER, HOW MANY DELIVERED ROLLS (HAD AT LEAST 1 CHANGE ) AND (HOW MANY DON'T HAVE)?

SELECT customer_id,COUNT(roll_id),chg_nochg FROM(
SELECT *,CASE WHEN new_not_include_items = '0' AND new_extra_items_incuded = '0' THEN 'No Change' ELSE 'Change' END chg_nochg
FROM customer_order_new 
WHERE order_id IN ( SELECT order_id FROM driver_order_new
				   WHERE new_cancellation <> 0 ))a
GROUP BY customer_id,chg_nochg
ORDER BY customer_id;  

-- 8) HOW MANY ROLLS WERE DELIVERED THAT HAD BOTH EXCLUSINS AND EXTRAS? 

SELECT COUNT(order_id),chg_nochg FROM (
SELECT *,CASE WHEN new_not_include_items != '0' AND new_extra_items_incuded !='0' THEN 'Either 1' ELSE 'Both' END chg_nochg
FROM customer_order_new
WHERE order_id IN ( SELECT order_id FROM driver_order_new
					WHERE new_cancellation <> 0 ) ) AS a
GROUP BY chg_nochg;


-- 9) WHAT WAS THE TOTAL NUMBER OF ROLLS ORDERED FOR EACH HOUR OF THE DAY?

SELECT hr_range,COUNT(roll_id) AS no_of_rolls FROM(
SELECT *,CONCAT(EXTRACT(hour FROM order_date) ,'-',EXTRACT(hour FROM order_date)+1) AS hr_range FROM customer_order_new) AS a
GROUP BY hr_range
ORDER BY hr_range;


-- 10) WHAT WAS THE NUMBER OF ORDERS FOR EACH DAY OF WEEK?

SELECT dow,COUNT(DISTINCT order_id) AS no_of_orders 
FROM(SELECT *,dayname(order_date) AS dow FROM customer_order_new) a
GROUP BY dow 
ORDER BY no_of_orders DESC;





-- 11) WHAT WAS THE AVERAGE TIME IN MINUTES IT TOOK FOR EACH DRIVER TO ARRIVE AT THE FAASOS HQ TO PICKUP THE ORDER?

SELECT driver_id, ROUND(AVG(DIFF)) AS avg_time_min FROM (
SELECT a.order_id ,d.driver_id,order_date,d.pickup_time ,time_to_sec((TIMEDIFF(pickup_time,order_date)))/60 AS DIFF
FROM (SELECT order_id,order_date FROM customer_order_new
	  GROUP BY order_id,order_date) As a
	  JOIN driver_order_new AS d
		ON a.order_id = d.order_id
	  WHERE pickup_time IS NOT NULL ) b
GROUP BY driver_id;

-- EXPLANATION
-- firstly grouping order_id and order_time it means delivery will be counted single time as customer has order multiple items
-- then join with driver_order table for pickup_time then eliminating null values from pickup_time means which were cancelled
-- then making a time diff of (order_date, pick time) and converting it into minutes
-- gruping them by driver_id and cal avg time for each driver 


-- 12) IS THERE ANY RELATION BETWEEN THE NUMBER OF ROLLS AND HOW LONG THE ORDER TO PREPARE?

SELECT order_id,no_of_rolls, ROUND( time_to_sec((TIMEDIFF(pickup_time,order_date)))/60) AS prepare_time 
FROM (SELECT order_id,customer_id,order_date,pickup_time,count(roll_id) AS no_of_rolls 
FROM (SELECT con.*,d.pickup_time FROM customer_order_new con
	  JOIN driver_order_new d
		ON d.order_id = con.order_id
	  WHERE d.pickup_time IS NOT NULL ) a
GROUP BY order_id,customer_id,order_date,pickup_time) b;



-- 13) WHAT WAS THE AVERAGE DISTANCE TRAVELLED FOR EACH CUSTOMER

SELECT con.customer_id, ROUND(AVG(don.distance)) AS AVG_dis_trav_KM
FROM driver_order_new don, customer_order_new con
WHERE don.order_id=con.order_id AND pickup_time <> 0 
GROUP BY customer_id;


-- 14) WHAT IS THE DIFFERENCE BETWEEN THE LONGEST AND SHORTEST DELIVERY TIMES FOR ALL ORDERS?

SELECT MAX(duration_new)-MIN(duration_new) AS diff_max_min FROM (
SELECT duration,CASE WHEN duration LIKE '%min%' THEN LEFT(duration,position('m' IN duration)-1) 
ELSE duration END AS duration_new FROM driver_order_new
WHERE duration <> 0)a;


-- 15) WHAT WAS THE AVERAGE SPEED FOR EACH DRIVER FOR EACH DELIVERY AND DO YOU NOTICE ANY TREND FOR THESE VALUES?
-- as no of rolls increase the speed decrese 

SELECT a.order_id,driver_id,ROUND(distance_km/(duration_min/60)) AS speed_km_per_hr,COUNT(roll_id) AS no_of_rolls FROM(
SELECT order_id,driver_id,
	   CASE WHEN distance LIKE '%km%' THEN LEFT(distance,position('k'IN distance)-1) ELSE distance END AS distance_km,
       CASE WHEN duration LIKE '%min%' THEN LEFT(duration,position('m' IN duration)-1) ELSE duration END AS duration_min 
FROM driver_order_new
WHERE pickup_time <> 0) a,customer_order_new AS con
WHERE a.order_id = con.order_id
GROUP BY a.order_id,driver_id,speed_km_per_hr;


-- 16) WHAT IS THE SUCCESFUL DELIVERY PERCENTAGE FOR EACH DRIVER?

SELECT driver_id,(delivered/orders)*100 AS sucess_deliver_perc FROM (
SELECT driver_id,SUM(new_cancellation) AS delivered,COUNT(new_cancellation) AS orders FROM driver_order_new
GROUP BY driver_id)a





-- ----END---- --