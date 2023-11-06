SELECT p."vendorID", p."layerID", vlp."description",
       SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END) AS "accepted",
       SUM(CASE WHEN LOWER(p."requestResult") != 'accepted' THEN 1 ELSE 0 END) AS "filtered",
       COUNT(*) AS " total count",
       COUNT(lp."leadID") AS "leadsWon",
       CASE WHEN SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END) > 0 AND COUNT(lp."leadID") > 0 THEN ROUND((COUNT(lp."leadID")::decimal / SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END)::decimal) * 100, 4) ELSE 0 END AS "winRate",
       SUM(CASE WHEN lp."leadResult" = 'Accepted' THEN 1 ELSE 0 END) AS "leadsAccepted",
       CASE WHEN SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END) > 0 AND COUNT(lp."leadID") > 0 THEN ROUND((SUM(CASE WHEN lp."leadResult" = 'Accepted' THEN 1 ELSE 0 END)::decimal / SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END)::decimal) * 100, 4) ELSE 0 END AS "adjustedWinRate",
       ROUND(AVG(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN p."bid" * 0.01 END), 2) AS "avgBid$",
       COUNT(DISTINCT p."trustedFormCertID") AS "unique_certs",
       CASE WHEN COUNT(lp."leadID") > 0 AND SUM(CASE WHEN lc."conversion" = true OR lc."crmSold" = true OR lc."submittedApp" = true THEN 1 ELSE 0 END) > 0 THEN ROUND((SUM(CASE WHEN lc."conversion" = true OR lc."crmSold" = true OR lc."submittedApp" = true THEN 1 ELSE 0 END)::decimal / SUM(CASE WHEN lp."leadResult" = 'Accepted' THEN 1 ELSE 0 END)::decimal) * 100, 4) ELSE 0 END AS "conversionRate"

FROM public.pings_prod p
  LEFT JOIN public.leads_prod lp
    ON p."leadID" = lp."leadID"
  LEFT JOIN public.lead_conversions lc
    ON lp."leadID" = lc."leadID"
  LEFT JOIN public.vendor_layers_prod vlp
    ON p."layerID" = vlp."layerID"

-- if not using liquid filtering replace "{{ [variable] }}" with the actual value
WHERE DATE(p."created") >= '{{ start_date }}' AND DATE(p."created") <= '{{ end_date }}'
  AND p."networkID" IN ({{ network }})

GROUP BY p."vendorID", p."layerID", vlp."description";