-- For this project, we will learn how to use SQL, UTM parameters, and touch attribution to draw insights from this data.


/*----------------------------------*/
/* Get familiar with CoolTShirts */

-- Number of distinct campaigns.
SELECT COUNT(DISTINCT utm_campaign)
FROM page_visits;

-- Number of distinct sources.
SELECT COUNT(DISTINCT utm_source)
FROM page_visits;

-- Which source is used for each campaign?
SELECT DISTINCT utm_campaign,
  utm_source
FROM page_visits;

-- What pages are on the CoolTShirts website?
SELECT DISTINCT page_name
FROM page_visits;

-- Total number of unique users.
SELECT COUNT(DISTINCT user_id)
FROM page_visits;



/*----------------------------------*/
/* What is the user journey? */

-- How many first touches is each campaign responsible for?
-- Note that ft_attr temporary table is not needed but we are using it because the project used it in the solution. We can instead, directly create a query and avoid the ft_attr table. 
WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id),
ft_attr AS (
  SELECT ft.user_id,
         ft.first_touch_at,
         pv.utm_source,
		     pv.utm_campaign
  FROM first_touch ft
  JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp
)
SELECT ft_attr.utm_source,
       ft_attr.utm_campaign,
       COUNT(*)
FROM ft_attr
GROUP BY 1, 2
ORDER BY 3 DESC;

-- How many last touches is each campaign responsible for?
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id),
lt_attr AS (
  SELECT lt.user_id,
         lt.last_touch_at,
         pv.utm_source,
		     pv.utm_campaign
  FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source,
       lt_attr.utm_campaign,
       COUNT(*)
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;

-- How many visitors make a purchase?
SELECT COUNT( DISTINCT user_id)
FROM page_visits
WHERE page_name = '4 - purchase';

-- How many last touches on the purchase page is each campaign responsible for?
  -- The WHERE clause should be used in the WITH stmt because a user may have purchased an item in page 4, but might have came back to the website. Using the WHERE inside WITH assures the MAX(timestamp) is for the most recent purchase. For exmaple, user_id 29180, 76466, 94852 would be counted here even though they came back to the website after the purchase.
  -- If WHERE is used outside of WITH, then the MAX(timestamp) in the first temporary table will select the timestamp of the user when he came back. Which means the '4 - purchase' would be excluded. For example, user_id 29180, 76466, 94852 would NOT be counted because there absolute last touch MAX(timestmap) was when they came back.
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    WHERE page_name = '4 - purchase' -- WHERE clause was added
    GROUP BY user_id),
lt_attr AS (
  SELECT lt.user_id,
         lt.last_touch_at,
         pv.utm_source,
		     pv.utm_campaign
  FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source,
       lt_attr.utm_campaign,
       COUNT(*)
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;

-- CoolTshirts can re-invest in 5 campagins. Which should they pick and why?
-- It depends if you look at first or last touch. See the powerpoint presentation for details. 





