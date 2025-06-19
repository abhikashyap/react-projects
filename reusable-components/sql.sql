DROP MATERIALIZED VIEW IF EXISTS public.offers;
DROP MATERIALIZED VIEW IF EXISTS public.fk_pricing_filter;

CREATE MATERIALIZED VIEW public.fk_pricing_filter AS
WITH scrapper_clean AS (
  SELECT
    fsn,
    CAST(REPLACE(REPLACE(price, '₹', ''), ',', '') AS INTEGER) AS price,
    updated_at
  FROM public.scrapper_liveprice
  WHERE price ~ '^\d+[\d,]*$' AND TRIM(price) NOT IN ('', '0')
),
html_clean AS (
  SELECT
    fsn,
    CAST(REPLACE(REPLACE(price, '₹', ''), ',', '') AS INTEGER) AS price,
    updated_at
  FROM public.fk_product_html
  WHERE price ~ '^\d+[\d,]*$' AND TRIM(price) NOT IN ('', '0')
),
scrapper_changes AS (
  SELECT 
    fsn,
    price,
    LAG(price) OVER (PARTITION BY fsn ORDER BY updated_at) AS prev_price,
    updated_at,
    'scrapper_liveprice' AS source
  FROM scrapper_clean
),
html_changes AS (
  SELECT 
    fsn,
    price,
    LAG(price) OVER (PARTITION BY fsn ORDER BY updated_at) AS prev_price,
    updated_at,
    'fk_product_html' AS source
  FROM html_clean
),
filtered_changes AS (
  SELECT * FROM scrapper_changes
  WHERE price IS DISTINCT FROM prev_price OR prev_price IS NULL
  UNION ALL
  SELECT * FROM html_changes
  WHERE price IS DISTINCT FROM prev_price OR prev_price IS NULL
),
latest_scrapper AS (
  SELECT DISTINCT ON (fsn) 
    fsn, price, updated_at, 'scrapper_liveprice' AS source
  FROM scrapper_clean
  ORDER BY fsn, updated_at DESC
),
latest_html AS (
  SELECT DISTINCT ON (fsn)
    fsn, price, updated_at, 'fk_product_html' AS source
  FROM html_clean
  ORDER BY fsn, updated_at DESC
),
latest_prices AS (
  SELECT * FROM latest_scrapper
  UNION ALL
  SELECT * FROM latest_html
),
latest_missing_only AS (
  SELECT lp.*
  FROM latest_prices lp
  LEFT JOIN filtered_changes fc ON lp.fsn = fc.fsn
  WHERE fc.fsn IS NULL
),
combined_result AS (
  SELECT fsn, price, prev_price, updated_at, source FROM filtered_changes
  UNION ALL
  SELECT fsn, price, NULL AS prev_price, updated_at, source FROM latest_missing_only
)
SELECT 
  row_number() OVER () AS id,
  fsn,
  price,
  prev_price,
  updated_at,
  source
FROM combined_result
ORDER BY fsn, updated_at DESC;

-- Optional index for lookups
CREATE INDEX idx_fk_pricing_filter_fsn ON public.fk_pricing_filter(fsn);
-- DROP MATERIALIZED VIEW IF EXISTS public.catalog_description;
-- CREATE MATERIALIZED VIEW catalog_description AS 
-- WITH cleaned_data AS (
--     SELECT 
--         fsn,
--         title,

--         -- Clean and cast MRP
--         CASE
--             WHEN mrp IS NULL OR mrp = ''
--                 THEN 0
--             ELSE CAST(FLOOR(CAST(REPLACE(REPLACE(mrp, '₹', ''), ',', '') AS NUMERIC)) AS INTEGER)
--         END AS mrp,

--         -- Clean and cast Final Selling Price
--         CASE
--             WHEN final_selling_price IS NULL OR final_selling_price = ''
--                 THEN 0
--             ELSE CAST(FLOOR(CAST(REPLACE(REPLACE(final_selling_price, '₹', ''), ',', '') AS NUMERIC)) AS INTEGER)
--         END AS price,

--         -- Clean and cast Rating
--         CASE
--             WHEN rating IS NULL OR rating = ''
--                 THEN 0
--             ELSE CAST(rating AS DECIMAL)
--         END AS rating,

--         -- Safe extract for rating_count
--         CASE
--             WHEN ratings_count IS NULL OR ratings_count = ''
                 
--                 THEN 0
--             ELSE CAST(ratings_count AS INTEGER)
--         END AS rating_count,

--         -- Clean and cast review_count
--         CASE
--             WHEN reviews_count IS NULL OR reviews_count = ''
--                 THEN 0
--             ELSE CAST(reviews_count AS INTEGER)
--         END AS review_count,

--         description,
--         brand_name as brand,
--         price_per_unit,
--         highlights::text,
--         all_specs::text AS specification,
--         image_urls AS images,
-- 		reviews,
-- 		seller_rating,
-- 		brand_name,
-- 		product_category,
-- 		rating_info,
		
--         updated_at::date

--     FROM public.flipkart_product
-- ),

-- ranked_data AS (
--     SELECT *,
--            ROW_NUMBER() OVER (PARTITION BY fsn ORDER BY updated_at DESC) AS row_num
--     FROM cleaned_data
-- )

-- SELECT *
-- FROM ranked_data
-- WHERE row_num = 1;

-- CREATE UNIQUE INDEX idx_catalog_description_fsn ON catalog_description(fsn);
DROP MATERIALIZED VIEW IF EXISTS public.offers;

CREATE MATERIALIZED VIEW offers AS
(
WITH base AS (
    SELECT *,
      MAX(price) OVER (PARTITION BY fsn) AS max_price,
      MAX(price) OVER (PARTITION BY fsn) - price AS diff_price,
      ROUND(
        100.0 * (MAX(price) OVER (PARTITION BY fsn) - price) 
        / NULLIF(MAX(price) OVER (PARTITION BY fsn), 0), 2
      ) AS diff_percent
    FROM public.fk_pricing_filter
    WHERE updated_at > CURRENT_DATE - INTERVAL '30 days'
  ),
  price_drop AS (
    SELECT *
    FROM base
    WHERE updated_at::date = CURRENT_DATE AND price > 500
    ORDER BY diff_percent DESC
  ),
  filter AS (
    SELECT 
      pd.fsn,
      pd.updated_at::date AS updated_at,
      pd.price,
      pd.max_price,
      pd.diff_price,
      pd.diff_percent,
      cd.title,
      cd.mrp,
      cd.rating,
      cd.ratings_count as rating_count,
      cd.reviews_count as review_count,
      CAST(cd.image_urls AS jsonb) AS images,
      cd.brand_name,
      cd.brand_name as brand,
      cd.product_category->>'vertical' AS vertical,
      cd.product_category->>'superCategory' AS supercategory,
      cd.product_category->>'category' AS category,
      cd.product_category->>'subCategory' AS subCategory
    FROM price_drop pd
    INNER JOIN public.flipkart_product cd 
      ON pd.fsn = cd.fsn
    WHERE cd.rating_info->'rating'->>'average' IS NOT NULL 
      AND (cd.rating_info->'rating'->>'average')::numeric >= 3.5
      AND cd.rating_info->'rating'->>'reviewCount' IS NOT NULL 
      AND (cd.rating_info->'rating'->>'reviewCount')::integer >= 50
  )
  SELECT * FROM filter
);
create index idx_offers_category on offers(category);