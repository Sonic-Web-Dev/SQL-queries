SELECT *

FROM (SELECT DATE_TRUNC('hour', "created") AS "date", "vendorID", "layerID",
       COUNT(*) AS "count"

FROM public.leads_prod lp

WHERE lp."networkID" IN ({{ networkid }})
  AND "leadResult" = 'Accepted'
  AND DATE_TRUNC('hour', "created") >= DATE(NOW()) - INTERVAL '45 days'

GROUP BY "date", "vendorID", "layerID") q

WHERE "count" > 0;