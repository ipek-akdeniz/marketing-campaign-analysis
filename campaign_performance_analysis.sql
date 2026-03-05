WITH combined_ads AS (

SELECT 
    ad_date,
    url_parameters,
    'facebook' AS source,
    COALESCE(spend,0) AS spend,
    COALESCE(impressions,0) AS impressions,
    COALESCE(clicks,0) AS clicks,
    COALESCE(value,0) AS value
FROM facebook_ads_basic_daily

UNION ALL

SELECT 
    ad_date,
    url_parameters,
    'google' AS source,
    COALESCE(spend,0) AS spend,
    COALESCE(impressions,0) AS impressions,
    COALESCE(clicks,0) AS clicks,
    COALESCE(value,0) AS value
FROM google_ads_basic_daily

)

SELECT 
    ad_date,
    
    LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)')) AS utm_campaign,

    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(value) AS total_value,

    CASE 
        WHEN SUM(impressions)=0 THEN NULL
        ELSE SUM(spend)::float / SUM(impressions) * 1000
    END AS cpm,

    CASE
        WHEN SUM(clicks)=0 THEN NULL
        ELSE SUM(spend)::float / SUM(clicks)
    END AS cpc,

    CASE
        WHEN SUM(impressions)=0 THEN NULL
        ELSE SUM(clicks)::float / SUM(impressions)
    END AS ctr,

    CASE
        WHEN SUM(spend)=0 THEN NULL
        ELSE (SUM(value) - SUM(spend))::float / SUM(spend)
    END AS romi

FROM combined_ads
GROUP BY 
    ad_date,
    utm_campaign;
