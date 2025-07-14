# Post-Purchase Retention Analysis with GA4 + BigQuery
SQL analysis using BigQuery to identify when users return to a website after making their first purchase, based on GA4 exported data.

This repository contains a step-by-step SQL query that identifies the first time users return to a website after making a purchase, using Google Analytics 4 (GA4) data exported to BigQuery.

The analysis focuses on:
- Detecting the first conversion per user (event_name = 'purchase')
- Comparing user behavior in sessions that occur *after* the purchase
- Identifying the **first session after the purchase** that is distinct from the purchase session
- Measuring how many **days it took** the user to come back

This is useful for understanding user retention, post-conversion engagement, and behavioral patterns that can inform remarketing or lifecycle strategies.

Ideal for eCommerce, product analytics, or marketing data teams working with GA4 + BigQuery.

✅ SQL only  
📦 Dataset: `bigquery-public-data.ga4_obfuscated_sample_ecommerce`  
📊 Output: 1 row per user with return session timestamp and time to return (in days)
