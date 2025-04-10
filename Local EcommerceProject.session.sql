-- Before insights, need to convert EUR to USD. 
UPDATE products
SET price_usd = ROUND(price * 1.08)

ALTER TABLE products
RENAME COLUMN price TO price_eur


--------------------------------------------------------------------------------------------------------------------------------------------


-- What are the top 10 colors that generated the most revenue?

SELECT
    LOWER(TRIM(product_color)) AS color,
    SUM(price_usd * units_sold) AS total_revenue,
    SUM(units_sold) AS total_units_sold
FROM 
    products
WHERE
    product_color IS NOT NULL
GROUP BY
    color
ORDER BY
    total_units_sold DESC
LIMIT 10

/*
Business Insight:
Identified which product colors generated the highest units sold to help guide future marketing, inventory, and 
design decisions. Next, I explored further to see if the higher sold colors correlates with higher ratings. 
*/


--------------------------------------------------------------------------------------------------------------------------------------------


-- Do higher-selling colors correlate with higher ratings?

WITH HighestSellingColors AS (
    SELECT
        LOWER(TRIM(product_color)),
        SUM(units_sold) AS total_units_sold,
        ROUND(AVG(rating), 2) AS avg_rating
    FROM 
        products
    WHERE
        product_color IS NOT NULL 
    GROUP BY
        LOWER(TRIM(product_color))
),

RankedColors AS (
    SELECT *,
        RANK() OVER (ORDER BY total_units_sold DESC) AS rank_sales,
        RANK() OVER (ORDER BY avg_rating DESC) AS rank_rating
    FROM
        HighestSellingColors
)

SELECT *
FROM RankedColors
ORDER BY rank_rating;
/*
Business Insight:
Ranked product colors based on both total units sold and average customer rating to explore whether top-selling 
colors also receive high satisfaction scores. Interestingly, some of the highest-sellings colors did not rank 
among the top-rated, suggesting that popularity does not always correlate with satisfaction. On the other hand,
colors like purple and multicolor showed strong performance in both metrics, indicating high customer appeal and 
satisfaction. 
*/


--------------------------------------------------------------------------------------------------------------------------------------------


-- Which sellers generated the highest total profit and how does their average discount relate to their overall performance?

-- Since we cannot clarify the data. Let us assume shipping_option_price is paid by the merchant, therefore it being an expense. 

WITH product_profits AS (
    SELECT
        merchant_id,
        SUM((price_usd - shipping_option_price) * units_sold) AS total_profit,
        SUM(units_sold) AS total_units_sold
    FROM 
        products
    GROUP BY
        merchant_id
)

SELECT
    sm.merchant_id,
    sm.rating AS merchant_rating,
    sm.average_discount,
    pp.total_profit,
    pp.total_units_sold
FROM 
    product_profits pp
    INNER JOIN seller_metrics sm ON pp.merchant_id = sm.merchant_id
ORDER BY
    pp.total_profit DESC;

/*
Business Insight:
This analysis identifies which merchants generated the highest total profit by calculating net earnings.
By joining seller metrics data, I was able to compare profitability with merchant ratings and discount
behavior. Merchants with high profits and high customer ratings represent strong business partners with potential 
for promotion or preferred visibility. On the other hand, sellers with high profits but lower ratings or minimal
discounts may be benefiting from strong demand but could risk long-term satisfaction and retention. This insight
helps stakeholders understand which merchants are both profitable and customer-centric, and which might need 
attention from a product or customer sentiment perspective. 
*/


--------------------------------------------------------------------------------------------------------------------------------------------


-- Which sellers are overperforming or underperforming based on their average discount strategy and how do their sales and ratings compare?

-- Assume average_discount column was given a negative value by mistake. 
SELECT
    p.merchant_title,
    p.merchant_id,
    ABS(sm.average_discount),
    SUM((p.price_usd - p.shipping_option_price) * p.units_sold) AS total_profit,
    CASE
        WHEN sm.average_discount >= 30 THEN 'Aggressive Discounting'
        WHEN sm.average_discount BETWEEN 10 AND 29 THEN 'Moderate Discounting'
        WHEN sm.average_discount <= 10 THEN 'Low Discount'
        ELSE 'UnKnown'
    END AS discount_strategy
FROM
    products AS p
    INNER JOIN seller_metrics AS sm ON sm.merchant_id = p.merchant_id
GROUP BY
    discount_strategy,
    p.merchant_title,
    p.merchant_id,
    sm.average_discount
ORDER BY
    total_profit DESC
LIMIT 15;

/*
Business Insight:
In this analysis, I categorized sellers based on their average discount behavior and compared that to their total profits. 
Using a CASE WHEN statement, I segmented sellers into Aggressive, Moderate, and Low Discounting strategies based on their 
average discount values. This allowed me to explore whether aggressive discounting truly leads to higher sales or if sellers with more
modest pricing strategies perform better in terms of volume or customer satisfaction. The results provide stakeholders a way to 
evaulate discount effectiveness and identify which pricing strategies are driving the most customer engagement and long-term value. 
This insight can help teams make smarter decisions about seller support, promotional visibility, and pricing strategy across the platform. 
*/

