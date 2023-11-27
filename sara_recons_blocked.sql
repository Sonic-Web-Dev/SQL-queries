CREATE TABLE sara_recons_blocked AS
SELECT DATE_TRUNC('hour', lp."created") AS "createdDate", lp."networkID",
       CASE WHEN lp."requestResult" IS NOT NULL THEN lrx."leadResult" ELSE CAST(lp."leadResult" AS varchar(100)) END AS "leadResult",
       lp."vendorID",
       COUNT(lp."leadID") AS "total blocked",
       SUM(CASE WHEN lpp."isOriginal" = true THEN 1 ELSE 0 END) AS "unique vendor",
       SUM(CASE WHEN lp."requestResult" = 'ushgGTB' THEN 1 ELSE 0 END) AS "gtb checks",
       SUM(CASE WHEN lp."requestResult" != 'ushgGTB' THEN 1 ELSE 0 END) AS "sonic checks",
       SUM(lp."buyerPrice") * 0.01 AS "vendor costs"

FROM public.leads_prod lp
  LEFT JOIN public.leads_phone_prod lpp
    ON lp."leadID" = lpp."leadID"
  LEFT JOIN public.lead_result_xref lrx
    ON lp."requestResult" = lrx."requestResult"

WHERE DATE_TRUNC('day', lp."created") >= '2023-01-01'
  AND lp."leadType" != 'recycled'
  AND lp."leadResult" != 'Accepted'

GROUP BY "createdDate", lp."networkID", lp."leadResult", lp."vendorID", lp."requestResult", lrx."leadResult"
ORDER BY COUNT(lp."leadID") DESC;