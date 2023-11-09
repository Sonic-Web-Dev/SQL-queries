SELECT *

FROM (SELECT DATE_TRUNC('hour', "created") AS "date", "name", "description", "layerID",
       COUNT(*) AS "count"

FROM public.leads_prod lp
  INNER JOIN public.leads_sold_prod lsp
    ON lp."leadID" = lsp."leadID"
  INNER JOIN public.price_tiers_prod ptp
    ON lsp."tierID" = ptp."priceTierID"

/* replace "{{ networkid }}" with the actual networkID(s) wrapped in single quotes,
   separated by a comma if there are multiple networks you want to filter for. */
WHERE lp."networkID" IN ({{ networkid }})
  AND "leadResult" = 'Accepted'
  AND DATE_TRUNC('hour', "created") >= DATE(NOW()) - INTERVAL '7 days'

GROUP BY "date", "name", "description", "layerID") q

WHERE "count" > 0;