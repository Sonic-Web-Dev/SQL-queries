SELECT p."networkID", DATE_TRUNC('hour', p."created") AS "date", p."vendorID", p."mpVendorCampaignID", p."resultMessage", COUNT(p."resultMessage") AS "Ping Count",
  SUM(CASE WHEN lp."leadID" IS NOT NULL AND lp."leadResult" = 'Accepted' THEN 1 ELSE 0 END) AS "Leads Won",
  AVG(CASE WHEN p."bid" IS NOT NULL THEN p."bid"/100 ELSE 0 END) AS "AVG Bid", ROUND(AVG(CASE WHEN p."ageInt" > 17 AND p."ageInt" < 101 THEN p."ageInt" END)) AS "AVG Age",
  ROUND(AVG(CASE WHEN p."householdInt" >= 0 AND p."householdInt" <= 10 THEN p."householdInt" END)) AS "AVG Household",
  ROUND(AVG(CASE WHEN p."incomeInt" > 29999 AND p."incomeInt" < 500000 THEN p."incomeInt" END)) AS "AVG Income"

FROM public."pings_prod" p
  LEFT JOIN public."leads_prod" lp
    ON p."leadID" = lp."leadID"
  INNER JOIN public."vendor_campaigns_prod" vcp
    ON p."mpVendorCampaignID" = vcp."mpVendorCampaignID"

WHERE p."created" >= '{start_date}' AND p."created" < '{end_date}'

GROUP BY p."networkID", DATE_TRUNC('hour', p."created"), p."vendorID", p."mpVendorCampaignID", p."resultMessage";
