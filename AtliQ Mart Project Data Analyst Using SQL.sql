SELECT * FROM retail_events_db.dim_campaigns;
SELECT * FROM retail_events_db.dim_products;
SELECT * FROM retail_events_db.dim_stores;
SELECT * FROM retail_events_db.fact_events;

-- ------------------------------------Store Performance Analysis:-----------------------------
-- Q1. Which are the top 10 stores in term of incremental revenue (IR) generated from promotion ?

SELECT 
	store_id
    base_price, 
    `quantity_sold(before_promo)`, 
    `quantity_sold(after_promo)`,
    base_price * (`quantity_sold(after_promo)` - `quantity_sold(before_promo)`) AS incremental_revenue
FROM retail_events_db.fact_events
ORDER BY incremental_revenue DESC
LIMIT 10;

-- ----------------------------------------------------------X-------------------------------------------
-- Q2. Which are the bottom 10 stores when it comes to incremental sold unit (ISU) during the promotional period?

SELECT
	store_id
    base_price, 
    `quantity_sold(before_promo)`, 
    `quantity_sold(after_promo)`,
    `quantity_sold(after_promo)` - `quantity_sold(before_promo)` AS incremental_sold_units
FROM retail_events_db.fact_events
ORDER BY incremental_sold_units ASC
LIMIT 10;

-- --------------------------------------------X--------------------------------------
-- How does the performance of stores vary by city? Are there any common characteristics among the top-performing stores that could be leveraged across other stores ?
-- Q3.a Top 10 by city IR
SELECT 
	fe.store_id,
    ds.city,
    fe.base_price, 
    fe.`quantity_sold(before_promo)`, 
    fe.`quantity_sold(after_promo)`,
    base_price * (`quantity_sold(after_promo)` - `quantity_sold(before_promo)`) AS incremental_revenue
FROM 
    retail_events_db.dim_stores ds
JOIN 
    retail_events_db.fact_events fe ON ds.store_id = fe.store_id
    ORDER BY incremental_revenue DESC
LIMIT 10;

-- --------------------------------------------X--------------------------------------
-- How does the performance of stores vary by city? Are there any common characteristics among the top-performing stores that could be leveraged across other stores ?
-- Q3.b Bottom 10 by city ISU

SELECT 
	fe.store_id,
    ds.city,
    fe.base_price, 
    fe.`quantity_sold(before_promo)`, 
    fe.`quantity_sold(after_promo)`,
    `quantity_sold(after_promo)` - `quantity_sold(before_promo)` AS incremental_sold_units
FROM 
    retail_events_db.dim_stores ds
JOIN 
    retail_events_db.fact_events fe ON ds.store_id = fe.store_id
    ORDER BY incremental_sold_units ASC
LIMIT 10;

-- ------------------------------------Promotion Type Analysis:-----------------------------
-- --------------------------------------------X--------------------------------------
-- Q4. What are the top 2 promotion types that resulted in the highest incremental revenue ?

SELECT
    promo_type,
    SUM(base_price * (`quantity_sold(after_promo)` - `quantity_sold(before_promo)`)) AS total_incremental_revenue
FROM
    retail_events_db.fact_events
GROUP BY
    promo_type
ORDER BY
    total_incremental_revenue DESC
LIMIT 2;

-- --------------------------------------------X--------------------------------------
-- Q5. What are the bottom 2 promotion types in terms of their impact on Incremental Sold Units ?

SELECT
    promo_type,
    SUM(`quantity_sold(after_promo)` - `quantity_sold(before_promo)` ) AS incremental_sold_units
FROM
    retail_events_db.fact_events
GROUP BY
    promo_type
ORDER BY
    incremental_sold_units ASC
LIMIT 2;

-- --------------------------------------------X--------------------------------------
-- Q6. Which Promotion strike the best balance incremental sold Units and maintaining healthy margins ?
SELECT
    promo_type,
    SUM(`quantity_sold(after_promo)` - `quantity_sold(before_promo)`) AS total_incremental_sold_units,
    SUM(base_price * (`quantity_sold(after_promo)` - `quantity_sold(before_promo)`)) AS total_incremental_revenue,
    (SUM(`quantity_sold(after_promo)` - `quantity_sold(before_promo)`) / SUM(base_price * (`quantity_sold(after_promo)` - `quantity_sold(before_promo)`))) AS units_per_revenue
FROM
    retail_events_db.fact_events
GROUP BY
    promo_type
ORDER BY
    units_per_revenue DESC
LIMIT 1;

-- --------------------------------------------X--------------------------------------
-- Q7. Is there a significant diffrence in the performance of discount - basewd promotions versus BOGOF (BUY ONE GET ONE FREE) OR cashback promotions?

SELECT
    promo_type,
    SUM(base_price * (`quantity_sold(after_promo)` - `quantity_sold(before_promo)`)) AS total_incremental_revenue,
    SUM(`quantity_sold(after_promo)` - `quantity_sold(before_promo)`) AS total_incremental_sold_units
FROM
    retail_events_db.fact_events
WHERE
    promo_type IN ('25% OFF','33% OFF','50% OFF', 'BOGOF', '500 Cashback')
GROUP BY
    promo_type;

-- ------------------------------------Product and Category Analysis:-----------------------------   
-- --------------------------------------------X--------------------------------------
-- Q.8 Which product categories saw the most significant lift in sales from the promotions ?

SELECT
    dp.product_name,
    dp.category,
    fe.product_code,
    SUM(`quantity_sold(after_promo)` - `quantity_sold(before_promo)`) AS lift_in_sales
FROM
    retail_events_db.dim_products dp
JOIN 
    retail_events_db.fact_events fe ON dp.product_code = fe.product_code
GROUP BY
    dp.product_name,
    dp.category,
    fe.product_code
ORDER BY
    lift_in_sales DESC;

    
-- --------------------------------------------X--------------------------------------
-- Q9. Are there specific products that respond exceptionally well or poorly to promotions?

SELECT
    dp.product_name,
    dp.category,
    fe.product_code,
    AVG(`quantity_sold(after_promo)` - `quantity_sold(before_promo)`) AS avg_lift_in_sales
FROM
    retail_events_db.dim_products dp
JOIN 
    retail_events_db.fact_events fe ON dp.product_code = fe.product_code
GROUP BY
    dp.product_name,
    dp.category,
    fe.product_code
ORDER BY
    avg_lift_in_sales DESC;

-- --------------------------------------------X--------------------------------------
-- Q10. What is the correlation between product category and promotion type effective?

SELECT
    dp.category AS product_category,
    fe.promo_type,
    SUM(base_price * (`quantity_sold(after_promo)` - `quantity_sold(before_promo)`)) AS total_incremental_revenue
FROM
    retail_events_db.dim_products dp
JOIN 
    retail_events_db.fact_events fe ON dp.product_code = fe.product_code
GROUP BY
    dp.category,
    fe.promo_type
ORDER BY
    product_category,
    total_incremental_revenue DESC;
