SELECT *
FROM (SELECT * FROM
      (SELECT p."networkID", p."vendorID", mst."layerID" AS "mlLayer", mst."strategy",
             SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END) AS "ml_accepted",
             SUM(CASE WHEN LOWER(p."requestResult") = 'demand busy' THEN 1 ELSE 0 END) AS "ml_activeDemand",
             SUM(CASE WHEN LOWER(p."requestResult") NOT IN ('accepted', 'demand busy') THEN 1 ELSE 0 END) AS "ml_filtered",
             COUNT(*) AS "ml total count",
             COUNT(lp."leadID") AS "ml_leadsWon",
             CASE WHEN SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END) > 0 AND COUNT(lp."leadID") > 0
                  THEN ROUND((COUNT(lp."leadID")::decimal / SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END)::decimal)*100, 4) ELSE 0 END AS "ml_winRate",
             SUM(CASE WHEN lp."leadResult" = 'Accepted' THEN 1 ELSE 0 END) AS "ml_leadsAccepted",
             CASE WHEN SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END) > 0 AND COUNT(lp."leadID") > 0
                  THEN ROUND((SUM(CASE WHEN lp."leadResult" = 'Accepted' THEN 1 ELSE 0 END)::decimal / SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END)::decimal)*100, 4) ELSE 0 END AS "ml_adjustedWinRate",
             ROUND(AVG(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN p."bid" * 0.01 END), 2) AS "ml_avgBid$",
             CASE WHEN COUNT(lp."leadID") > 0 AND SUM(CASE WHEN lc."conversion" = true OR lc."crmSold" = true OR lc."submittedApp" = true THEN 1 ELSE 0 END) > 0
                  THEN ROUND((SUM(CASE WHEN lc."conversion" = true OR lc."crmSold" = true OR lc."submittedApp" = true OR lsp."submittedApplication" = true OR cr."usha_leadid" IS NOT NULL THEN 1 ELSE 0 END)::decimal / SUM(CASE WHEN lp."leadResult" = 'Accepted' THEN 1 ELSE 0 END)::decimal)*100, 4) ELSE 0 END AS "ml_conversionRate"

      FROM pings_prod p
        INNER JOIN ml_results mlr
          ON p."leadID" = mlr."leadID"
        INNER JOIN ml_strategy_tracking mst
          ON p."layerID" = mst."layerID"
        LEFT JOIN leads_prod lp
          ON p."leadID" = lp."leadID"
        LEFT JOIN leads_sold_prod lsp
          ON lp."leadID" = lsp."leadID"
        LEFT JOIN lead_conversions lc
          ON lp."leadID" = lc."leadID"
        LEFT JOIN conversion_reports cr
          ON lp."corpLeadID" =  cr."usha_leadid"

      WHERE DATE_TRUNC('day', p."created") >= DATE_TRUNC('day', NOW()) - INTERVAL '60 days'
          AND p."layerID" IN (SELECT DISTINCT "layerID" FROM ml_strategy_tracking)

      GROUP BY p."networkID", p."vendorID", mst."layerID", mst."strategy"
      ORDER BY "ml_conversionRate" DESC) q) ml

  INNER JOIN (SELECT mst."layerID",
         SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END) AS "notML_accepted",
         SUM(CASE WHEN LOWER(p."requestResult") = 'demand busy' THEN 1 ELSE 0 END) AS "notML_activeDemand",
         SUM(CASE WHEN LOWER(p."requestResult") NOT IN ('accepted', 'demand busy') THEN 1 ELSE 0 END) AS "notML_filtered",
         COUNT(*) AS "notML_total count",
         COUNT(lp."leadID") AS "notML_leadsWon",
         CASE WHEN SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END) > 0 AND COUNT(lp."leadID") > 0
              THEN ROUND((COUNT(lp."leadID")::decimal / SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END)::decimal)*100, 4) ELSE 0 END AS "notML_winRate",
         SUM(CASE WHEN lp."leadResult" = 'Accepted' THEN 1 ELSE 0 END) AS "notML_leadsAccepted",
         CASE WHEN SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END) > 0 AND COUNT(lp."leadID") > 0
              THEN ROUND((SUM(CASE WHEN lp."leadResult" = 'Accepted' THEN 1 ELSE 0 END)::decimal / SUM(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN 1 ELSE 0 END)::decimal)*100, 4) ELSE 0 END AS "notML_adjustedWinRate",
         ROUND(AVG(CASE WHEN LOWER(p."requestResult") = 'accepted' THEN p."bid" * 0.01 END), 2) AS "notML_avgBid$",
         CASE WHEN COUNT(lp."leadID") > 0 AND SUM(CASE WHEN lc."conversion" = true OR lc."crmSold" = true OR lc."submittedApp" = true THEN 1 ELSE 0 END) > 0
              THEN ROUND((SUM(CASE WHEN lc."conversion" = true OR lc."crmSold" = true OR lc."submittedApp" = true OR lsp."submittedApplication" = true OR cr."usha_leadid" IS NOT NULL THEN 1 ELSE 0 END)::decimal / SUM(CASE WHEN lp."leadResult" = 'Accepted' THEN 1 ELSE 0 END)::decimal)*100, 4) ELSE 0 END AS "notML_conversionRate"

        FROM pings_prod p
          LEFT JOIN ml_results mlr
            ON p."leadID" = mlr."leadID"
          INNER JOIN ml_strategy_tracking mst
            ON p."layerID" = mst."layerID"
          LEFT JOIN leads_prod lp
            ON p."leadID" = lp."leadID"
          LEFT JOIN leads_sold_prod lsp
            ON lp."leadID" = lsp."leadID"
          LEFT JOIN lead_conversions lc
            ON lp."leadID" = lc."leadID"
          LEFT JOIN conversion_reports cr
            ON lp."corpLeadID" =  cr."usha_leadid"

        WHERE DATE_TRUNC('day', p."created") >= DATE_TRUNC('day', NOW()) - INTERVAL '60 days'
            AND mlr."leadID" IS NULL
            AND p."layerID" IN (SELECT DISTINCT "layerID" FROM ml_strategy_tracking)

        GROUP BY mst."layerID"
        ORDER BY "notML_conversionRate" DESC) notML
    ON ml."mlLayer" = notML."layerID";