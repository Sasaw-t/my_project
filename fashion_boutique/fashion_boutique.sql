-- Retail Fashion Boutique Project
-- Created by Sasawat Prasonkldee

-- preview data
select * 
from fashion_boutique
limit 10;

-- Data Cleaning

-- replace null values in return_reason
update fashion_boutique
set return_reason = 'No Return'
where return_reason IS NULL;

-- replace null values in customer_rating with average values
update fashion_boutique
set customer_rating = (
  select round(avg(customer_rating), 1)
  from fashion_boutique
  )
where customer_rating IS NULL;

-- replace null values in size
update fashion_boutique
set size = 'N/A'
where size IS NULL;


-- EDA

-- show total revenue
select sum(current_price) as total_revenue
from fashion_boutique;

-- shows revenue, number of products sold, average customer rating by category
select
    category,
    sum(current_price) as category_revenue,
    count(product_id) as items_sold,
    round(avg(customer_rating), 2) as average_category_rating
from fashion_boutique
group by category
order by category_revenue desc;

-- shows revenue, number of products sold, average customer rating by brand
select
    brand,
    sum(current_price) as brand_revenue,
    count(product_id) as items_sold,
    round(avg(customer_rating), 2) as average_brand_rating
from fashion_boutique
group by brand
order by brand_revenue desc;

-- shows revenue, number of products sold, average customer rating by season
select
    season,
    sum(current_price) as season_revenue,
    count(product_id) as items_sold,
    round(avg(customer_rating), 2) as average_season_rating
from fashion_boutique
group by season
order by season_revenue desc;

-- shows the most return reason
select
    return_reason,
    count(*) as return_count
from fashion_boutique
where is_returned = 1
group by return_reason
order by return_count desc;

-- shows the brand with the most returned products
select
    brand,
    count(*) as return_count
from fashion_boutique
where is_returned = 1
group by brand
order by return_count desc;

-- shows return rates by category
select
    category,
    round(sum(case 
          when is_returned = 1 then 1 
          else 0 
        end) * 1.0 / count(*), 3) as return_rate
from fashion_boutique
group by category
order by return_rate desc;

-- shows the products that are low in stock, sorted by customer rating
select
    product_id,
    category,
    brand,
    customer_rating,
    stock_quantity
from fashion_boutique
where stock_quantity <= 5
order by customer_rating desc;

-- show products with 5-star customer rating
select
    product_id,
    brand,
    category,
    customer_rating
from fashion_boutique
where customer_rating = 5.0
group by
    product_id,
    brand,
    category,
    customer_rating
order by
    brand,
    category;

-- shows the best-selling brand in each season
with ranked_brand_sales as (
    select
        season,
        brand,
        sum(current_price) as total_revenue,
        row_number() over(partition by season order by sum(current_price) desc) as rn
    from fashion_boutique
    group by
        season,
        brand
)
select
    season,
    brand,
    total_revenue
from ranked_brand_sales
where rn = 1;

-- shows the best-selling category in each season
with ranked_category_sales as (
    select
        season,
        category,
        sum(current_price) as total_revenue,
        row_number() over(partition by season order by sum(current_price) desc) as rn
    from fashion_boutique
    group by
        season,
        category
)
select
    season,
    category,
    total_revenue
from ranked_category_sales
where rn = 1;

-- shows the top 3 best-selling color in each season
with ranked_color_sales as (
    select
        season,
        color,
        count(*) as sales_count,
        row_number() over(partition by season order by count(*) desc) as rn
    from fashion_boutique
    group by
        season,
        color
)
select
    season,
    color,
    sales_count
from
    ranked_color_sales
where rn <= 3
order by
    season,
    sales_count desc;

-- show full price product compare discounted product
with product_type_sales as (
    select
        case
            when markdown_percentage = 0 then 'Full Price'
            else 'Discounted'
        end as product_type,
        sum(current_price) as total_revenue,
        count(*) as total_items_sold
    from fashion_boutique
    group by product_type
)
select
    product_type,
    total_revenue,
    total_items_sold
from product_type_sales
order by total_revenue desc;
