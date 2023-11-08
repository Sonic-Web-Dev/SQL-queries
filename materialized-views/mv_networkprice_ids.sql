CREATE MATERIALIZED VIEW mv_networkprice_ids AS
SELECT lp."networkID",
       ptmp."priceTierID"
FROM leads_prod lp
         JOIN price_tiers_mapping_prod ptmp ON lp."mpVendorCampaignID"::text = ptmp."mpVendorCampaignID"::text
GROUP BY lp."networkID", ptmp."priceTierID"
