CREATE MATERIALIZED VIEW sara_recons_blocked AS
SELECT DATE_TRUNC('hour', lp."created") AS "createdDate",
       lp."networkID",
       np."brokerID",
       CASE WHEN lpp."isBlacklisted" = true THEN 'blacklisted'
            WHEN lp."requestResult" = 'ushgGTB duplicate' AND lp."isDuplicate" = false THEN 'blacklisted'
            WHEN lp."requestResult" IS NOT NULL THEN lrx."leadResult"
            ELSE CAST(lp."leadResult" AS varchar(100)) END AS "leadResult",
       lp."vendorID",
       CASE WHEN mst."strategy" = 'buy_only_cheap' THEN true ELSE false END AS "mlLeads",
       COUNT(lp."leadID") AS "total blocked",
       SUM(CASE WHEN lpp."isOriginal" = true THEN 1 ELSE 0 END) AS "unique vendor",
       SUM(CASE WHEN lp."requestResult" LIKE '%ushgGTB%' THEN 1 ELSE 0 END) AS "gtb checks",
       SUM(CASE WHEN lp."requestResult" NOT LIKE '%ushgGTB%' THEN 1 ELSE 0 END) AS "sonic checks",
       SUM(lp."buyerPrice") * 0.01 AS "vendor costs"

FROM public.leads_prod lp
  LEFT JOIN public.leads_phone_prod lpp
    ON lp."leadID" = lpp."leadID"
  LEFT JOIN public.lead_result_xref lrx
    ON lp."requestResult" = lrx."requestResult"
  LEFT JOIN public.networks_prod np
    ON lp."networkID" = np."networkID"
  LEFT JOIN public.ml_strategy_tracking mst
    ON lp."layerID" = mst."layerID"

WHERE DATE_TRUNC('day', lp."created") >= '2023-01-01'
  AND lp."leadType" != 'recycled'
  AND lp."leadResult" != 'Accepted'

GROUP BY "createdDate", lp."networkID", np."brokerID", lp."leadResult", lp."vendorID", lp."requestResult",
         lrx."leadResult", lp."isDuplicate", lpp."isBlacklisted", mst."strategy"
ORDER BY COUNT(lp."leadID") DESC;
