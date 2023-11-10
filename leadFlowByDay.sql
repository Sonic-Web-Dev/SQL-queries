SELECT *

FROM (SELECT DATE_TRUNC('day', "created") AS "date", "vendorID", "layerID",
       COUNT(*) AS "count"

FROM public.leads_prod lp

/* replace "{{ networkid }}" with the actual networkID(s) wrapped in single quotes,
   separated by a comma if there are multiple networks you want to filter for. */
-- test
WHERE lp."networkID" IN ({{ networkid }})
  AND "leadResult" = 'Accepted'
  AND DATE_TRUNC('day', "created") >= DATE(NOW()) - INTERVAL '45 days'

GROUP BY "date", "vendorID", "layerID") q

WHERE "count" > 0;