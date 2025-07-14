-- Step 1: Get the first purchase timestamp and its session ID for each user
WITH first_conversion AS (
  SELECT
    user_pseudo_id,
    MIN(TIMESTAMP_MICROS(event_timestamp)) AS first_purchase,
    (SELECT value.int_value 
     FROM UNNEST(event_params) 
     WHERE key = "ga_session_id") AS session_id
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
  WHERE event_name = 'purchase'
  GROUP BY user_pseudo_id, session_id
),

-- Step 2: Join with all later events from the same user
-- Keep only those that occurred after the first purchase
-- Extract session ID of the post-purchase event to identify later sessions
event_after_purchase AS (
  SELECT
    fc.user_pseudo_id,
    fc.first_purchase,
    fc.session_id,
    COUNT(et.event_name) AS total_events_after,
    MIN(TIMESTAMP_MICROS(et.event_timestamp)) AS first_event_after_purchase,
    (SELECT value.int_value 
     FROM UNNEST(et.event_params) 
     WHERE key = "ga_session_id") AS session_id_after_purchase
  FROM first_conversion AS fc
  LEFT JOIN `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` AS et
    ON fc.user_pseudo_id = et.user_pseudo_id
  WHERE TIMESTAMP_MICROS(et.event_timestamp) > fc.first_purchase
  GROUP BY 
    fc.user_pseudo_id, 
    fc.first_purchase, 
    fc.session_id, 
    session_id_after_purchase
),

-- Step 3: Filter only sessions different from the purchase session
-- Use ROW_NUMBER to identify the first session the user returned in
st_first_sesion_after_first_purchase AS (
  SELECT 
    *,
    ROW_NUMBER() OVER(PARTITION BY user_pseudo_id ORDER BY first_event_after_purchase) AS rn,
    TIMESTAMP_DIFF(first_event_after_purchase, first_purchase, DAY) AS days_to_come_back
  FROM event_after_purchase
  WHERE session_id != session_id_after_purchase
)

-- Step 4: Select only the first session after the purchase for each user
SELECT
  *
FROM st_first_sesion_after_first_purchase
WHERE rn = 1
