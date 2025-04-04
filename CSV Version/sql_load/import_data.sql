-- Create seller_metrics table
CREATE TABLE public.seller_metrics (
    merchant_id TEXT PRIMARY KEY,
    listed_products INTEGER,
    total_units_sold INTEGER,
    mean_units_sold_per_product NUMERIC,
    rating NUMERIC,
    merchant_ratings_count INTEGER,
    mean_product_prices NUMERIC,
    mean_retail_prices NUMERIC,
    average_discount NUMERIC,
    mean_discount NUMERIC,
    mean_product_ratings_count NUMERIC,
    total_urgency_count NUMERIC,
    urgency_text_rate NUMERIC
);

-- Create products table
CREATE TABLE public.products (
    product_id TEXT PRIMARY KEY,
    merchant_id TEXT,
    price NUMERIC,
    retail_price NUMERIC,
    currency_buyer TEXT,
    units_sold INTEGER,
    rating NUMERIC,
    rating_count INTEGER,
    rating_five_count NUMERIC,
    rating_four_count NUMERIC,
    rating_three_count NUMERIC,
    rating_two_count NUMERIC,
    rating_one_count NUMERIC,
    product_color TEXT,
    product_variation_inventory INTEGER,
    shipping_option_name TEXT,
    shipping_option_price NUMERIC,
    countries_shipped_to INTEGER,
    inventory_total INTEGER,
    origin_country TEXT,
    merchant_title TEXT,
    merchant_rating NUMERIC,
  
    FOREIGN KEY (merchant_id) REFERENCES public.seller_metrics(merchant_id)
);

-- Create keywords_count table
CREATE TABLE public.keywords_count (
    keyword TEXT,
    counts INTEGER
);