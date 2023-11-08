SELECT * FROM
(SELECT p."networkID", p."vendorID", p."layerID", p."mlOverride",
       SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END) AS "accepted",
       SUM(CASE WHEN LOWER(p."requestResult") != 'accepted' THEN 1 ELSE 0 END) AS "filtered",
       COUNT(*) AS " total count",
       COUNT(lp."leadID") AS "leadsWon",
       CASE WHEN SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END) > 0 AND COUNT(lp."leadID") > 0
            THEN ROUND((COUNT(lp."leadID")::decimal / SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END)::decimal), 4) ELSE 0 END AS "winRate",
       SUM(CASE WHEN lp."leadResult" = 'Accepted' THEN 1 ELSE 0 END) AS "leadsAccepted",
       CASE WHEN SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END) > 0 AND COUNT(lp."leadID") > 0
            THEN ROUND((SUM(CASE WHEN lp."leadResult" = 'Accepted' THEN 1 ELSE 0 END)::decimal / SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END)::decimal), 4) ELSE 0 END AS "adjustedWinRate",
       ROUND(AVG(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN p."bid" * 0.01 END), 2) AS "avgBid$",
       COUNT(DISTINCT p."trustedFormCertID") AS "unique_certs",
       CASE WHEN COUNT(lp."leadID") > 0 AND SUM(CASE WHEN lc."conversion" = true OR lc."crmSold" = true OR lc."submittedApp" = true THEN 1 ELSE 0 END) > 0
            THEN ROUND((SUM(CASE WHEN lc."conversion" = true OR lc."crmSold" = true OR lc."submittedApp" = true OR lsp."submittedApplication" = true OR cr."usha_leadid" IS NOT NULL THEN 1 ELSE 0 END)::decimal / SUM(CASE WHEN lp."leadResult" = 'Accepted' THEN 1 ELSE 0 END)::decimal), 4) ELSE 0 END AS "conversionRate"

FROM pings_prod p
  INNER JOIN ml_results mlr
    ON p."leadID" = mlr."leadID"
  LEFT JOIN leads_prod lp
    ON p."leadID" = lp."leadID"
  LEFT JOIN leads_sold_prod lsp
    ON lp."leadID" = lsp."leadID"
  LEFT JOIN lead_conversions lc
    ON lp."leadID" = lc."leadID"
  LEFT JOIN conversion_reports cr
    ON lp."corpLeadID" =  cr."usha_leadid"

WHERE DATE(p."created") >= DATE(NOW()) - INTERVAL '60 days'
    AND (mlr."model_acc_Probability" >= .5 OR mlr."model_roc_Probability" >= .7 OR mlr."model_F1_Probability" >= .5 OR mlr."lgbm_conv_rate" >= .05)
    AND p."layerID" NOT IN (SELECT DISTINCT "layerID" FROM ml_strategy_tracking)

GROUP BY p."networkID", p."vendorID", p."layerID", p."mlOverride"
ORDER BY "conversionRate" DESC) q
WHERE "conversionRate" >= 0.01;