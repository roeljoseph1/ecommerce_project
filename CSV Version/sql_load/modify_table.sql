-- Products
COPY public.products
FROM 'C:\Users\bautistaroel\Desktop\Data Analysis Studies\Data Analyt\Data Analyst Portfolio Project\ecommerce_project\CSV Version\01_products.csv'
DELIMITER ','
CSV HEADER;

-- Seller metrics
COPY public.seller_metrics
FROM 'C:\Users\bautistaroel\Desktop\Data Analysis Studies\Data Analyt\Data Analyst Portfolio Project\ecommerce_project\CSV Version\02_seller_metrics.csv'
DELIMITER ','
CSV HEADER;

-- Keywords
COPY public.keywords_count
FROM 'C:\Users\bautistaroel\Desktop\Data Analysis Studies\Data Analyt\Data Analyst Portfolio Project\ecommerce_project\CSV Version\03_keywords_count.csv'
DELIMITER ','
CSV HEADER;

/*
pgAdmin 4 copy path process:

\copy products FROM 'C:\Users\bautistaroel\Desktop\Data Analysis Studies\Data Analyst Portfolio Project\ecommerce_project\CSV Version\01_products.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy seller_metrics FROM 'C:\Users\bautistaroel\Desktop\Data Analysis Studies\Data Analyst Portfolio Project\ecommerce_project\CSV Version\02_seller_metrics.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy keywords_count FROM 'C:\Users\bautistaroel\Desktop\Data Analysis Studies\Data Analyst Portfolio Project\ecommerce_project\CSV Version\03_keywords_count.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

*/

