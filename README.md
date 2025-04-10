# 🛒 Wish.com E-Commerce Sales Analysis

This project analyzes a real-world dataset from Wish.com, a global e-commerce platform, to uncover product trends, seller performance, and pricing strategies using SQL. The focus was on understanding which product colors sell the most, identifying top-performing sellers by profit, and exploring whether aggressive discount strategies on Wish actually lead to better customer satisfaction and sales outcomes. By mimicking real marketplace conditions, this project reflects how data analysts at companies like Wish can help improve product visibility, optimize pricing strategies, and support seller success across the platform.

📌 **Key Questions Explored:**
1. What product colors generate the most revenue?
2. Do high-selling colors correlate with high customer ratings?
3. Which sellers are the most profitable?
4. Are sellers with aggressive discounts actually performing better?

---

# 📂 Data Overview

The data comes from Kaggle and includes:
- Product information (color, price, units sold, ratings)
- Seller metrics (average discount, customer rating)
- Keyword insights (not deeply explored in this version)

---

# 🧰 Tools Used
- **SQL**: Core tool for querying and analyzing structured data
- **Excel**: Core tool for standardizing, cleaning, and analyzing unstructured data
  **Power BI**: Core tool for visualizing, analyzing, and sharing interactive data insights through dashboards and reports
- **PostgreSQL**: SQL "flavor" used for this project
- **Visual Studio Code**: Writing and testing SQL queries
- **Git & GitHub**: Version control and project publishing
---

# 🧼 Excel Data Cleaning & Preparation
Before performing SQL analysis, I conducted extensive data cleaning and formatting in Excel across all three datasets from Wish.com. This step ensured a clean, structured foundation for analysis.

# 🗂 Files Cleaned:
- **01_products_summer2020_clean**

- **02_seller_success_metrics_clean**

- **03_category_keywords_count_clean**

# ✅ Excel Cleaning Tasks Performed 

| Step            | Actions Taken                                                                                   |
|-----------------|--------------------------------------------------------------------------------------------------|
| **Column Audit**   | Renamed column headers for consistency (added underscores); dropped unused datasets            |
| **Formatting**     | Converted each sheet into structured Excel Tables for easier filtering and referencing        |
| **Cleaning**       | Removed duplicates, trimmed unnecessary columns, and standardized text values (e.g., `LOWER()` on keywords) |
| **Color Grouping** | Normalized alternate names for similar product colors (e.g., `"grey"`, `"Gray"`, `"GRAY"` → `gray`) |
| **Null Handling**  | Added placeholder null values where appropriate to preserve table structure                    |


# 📊 Highlights from Pivot Table Analysis:
- Top 3 selling product colors: black, white, and gray

- Lowest-selling colors: darkgreen, rainbow, and camel

- Shipping trends: standard shipping appeared most often, suggesting express options may be less popular

*Filtered Views Used:*

- Top 10 highest-grossing merchants

- Highest-rated merchants based on average rating

- These early Excel-based explorations helped shape the business questions I pursued in SQL, and allowed me to validate trends before committing to deeper analysis.

---

# 🔍 Key Insights

### 🟥 1. Top Product Colors by Revenue

> I calculated revenue per product color and found that even though colors like **black** and **white** had the highest unit sales, those colors didn’t always receive the highest ratings. This can help with inventory and marketing decisions.

```sql
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
```

### ⭐ 2. Correlation Between Sales and Ratings

> Using RANK() and a CTE, I compared the rank of each product color by total units sold and average customer rating. This helped reveal whether high-selling colors also received strong satisfaction scores. Interestingly, some of the highest-rated colors — like **tan and darkgreen** — had very low sales volume, while other colors such as **rosegold and black & white** demonstrated a more balanced performance between popularity and customer satisfaction. These insights can guide product visibility decisions and promotional strategies on platforms like Wish.

```sql
WITH HighestSellingColors AS (
    SELECT
        LOWER(TRIM(product_color)),
        SUM(units_sold) AS total_units_sold,
        AVG(rating) AS avg_rating
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
```
| Product Color     | Total Units Sold | Avg Rating | Rank (Sales) | Rank (Rating) |
|-------------------|------------------|------------|---------------|----------------|
| tan               | 100              | 5.00       | 81            | 1              |
| darkgreen         | 1                | 5.00       | 95            | 1              |
| rose red          | 100              | 4.67       | 81            | 3              |
| rosegold          | 20000            | 4.48       | 29            | 4              |
| silver            | 1100             | 4.37       | 63            | 5              |
| pink & white      | 100              | 4.35       | 81            | 6              |
| gray & white      | 1000             | 4.27       | 66            | 7              |
| black & white     | 30100            | 4.27       | 23            | 7              |
| camouflage        | 20100            | 4.25       | 26            | 9              |
| violet            | 1000             | 4.24       | 66            | 10             |
| coolblack         | 20100            | 4.20       | 26            | 11             |
| offwhite          | 1000             | 4.15       | 66            | 12             |
| pink & black      | 150              | 4.14       | 80            | 13             |
| black & yellow    | 20100            | 4.11       | 26            | 14             |
| floral            | 61000            | 4.11       | 18            | 14             |

*Table showcasing the ranks of the top rated colors, only displaying 15*

### 💰 3. Seller Profitability

> I calculated total profit per seller by subtracting shipping costs from sales. Sellers with high profits and high customer ratings are strong candidates for platform promotion, while high-profit/low-rating sellers may need review.

```sql
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
```

### 🧾 4. Discount Strategy vs. Performance

> Using a `CASE WHEN` to segment sellers into discount tiers, I found that **aggressive discounting** doesn’t always lead to better performance. Moderate strategies often perform just as well, offering insight into pricing optimization.
```sql
SELECT
    p.merchant_title,
    p.merchant_id,
    sm.average_discount,
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
    total_profit DESC;
```

| Merchant Title                      | Avg Discount (%) | Total Profit | Discount Strategy       |
|------------------------------------|------------------|--------------|--------------------------|
| FashionForChanny                   | 86               | 855000       | Aggressive Discounting  |
| ApparelHeaven                      | 54               | 780000       | Aggressive Discounting  |
| Pandolah Apparel Co.,Ltd          | 14               | 760000       | Low Discount            |
| SHENZHEN LONGDRAGON TECHNOLOGY CO.| 1                | 700042       | Low Discount            |
| fashionforgirls                    | 86               | 601200       | Aggressive Discounting  |
| f40051ab1zhong9                    | 7                | 570000       | Low Discount            |
| good999                            | 8                | 516000       | Low Discount            |
| fashionstore0408                   | 71               | 500000       | Aggressive Discounting  |
| freebird                           | 33               | 470000       | Aggressive Discounting  |
| HOT DRESS                          | 87               | 453100       | Aggressive Discounting  |
| GL                                 | 58               | 440000       | Aggressive Discounting  |
| leiston                            | 61               | 432600       | Aggressive Discounting  |
| Pentiumhorse                       | 4                | 408000       | Low Discount            |
| trendy_world                       | 88               | 400000       | Aggressive Discounting  |
| bigcompany                         | 85               | 400000       | Aggressive Discounting  |


*Table for Discount Streategy vs Performance, only displaying 15*


---

# 📈 SQL Techniques Highlighted
- **CTEs (`WITH`)** for reusable queries
- **`JOIN`** for combining seller + product data
- **`CASE WHEN`** for categorizing discount levels
- **Window Functions** like `RANK()` for performance comparisons
- **Data cleaning** with `LOWER(TRIM(...))`

---

# 📘 What I Learned

- How to transform raw product and seller data into business insights
- The power of SQL to explore multiple angles of a question
- How to present findings clearly for stakeholder impact
- Confidence using SQL tools like `CASE`, `RANK`, and `CTEs` together

---

# ✅ Conclusion

This project demonstrates real-world SQL analysis using an e-commerce dataset. The business questions tackled mirror common problems faced by online platforms: identifying top sellers, understanding customer preferences, and evaluating the impact of pricing strategy. The insights gained can help prioritize promotional strategies, improve customer satisfaction, and guide smarter decision-making.

---

### Closing Thoughts

This project provided valuable insight into the full scope of the data analyst workflow, from sourcing and preparing a dataset, to cleaning and standardizing it for analysis, and finally exploring it using SQL. While small in scale, the project offered a meaningful and realistic perspective on what end-to-end analysis looks like in practice. It highlights the thought process, technical steps, and decision-making involved in turning raw data into actionable insights.
