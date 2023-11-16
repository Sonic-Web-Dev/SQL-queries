/* Table for Total sums of EACH Network's Counts (not including blocked) */
CREATE TABLE sara_recons AS
SELECT DATE_TRUNC('hour', lsp."soldDate") AS "soldDates", lp."networkID", lp."vendorID", lsp."agentID", ap."email", ptp."name" AS "tier", lp."leadType", ptp."priceTierID" AS "tierID",
       COUNT(lsp."leadID") AS "lead count",
       SUM(CASE WHEN lsp."price" IS NOT NULL THEN lsp."price" ELSE 0 END) * 0.01 AS "agent spend",
       SUM(CASE WHEN lp."buyerPrice" IS NOT NULL THEN lp."buyerPrice" ELSE 0 END) * 0.01 AS "vendor costs"

FROM public.leads_prod lp
  INNER JOIN public.leads_sold_prod lsp
    ON lp."leadID" = lsp."leadID"
  INNER JOIN public.agents_prod ap
    ON lsp."agentID" = ap."agentID"
  INNER JOIN public.price_tiers_prod ptp
    ON lsp."tierID" = ptp."priceTierID"

WHERE lsp."soldDate" >= '2023-01-01'

GROUP BY "soldDates", lp."networkID", lp."vendorID", lsp."agentID", ap."email", "tier", lp."leadType", ptp."priceTierID"
ORDER BY COUNT(lsp."leadID") DESC;




/*
SELECT lp."networkID", lp."vendorID", lsp."agentID", ap."email", ptp."name" AS "tier", lp."leadType", ptp."isCrossNetwork",
       COUNT(lsp."leadID") AS "lead count",
       SUM(CASE WHEN lsp."price" IS NOT NULL THEN lsp."price" ELSE 0 END) * 0.01 AS "agent spend",
       SUM(CASE WHEN lp."buyerPrice" IS NOT NULL THEN lp."buyerPrice" ELSE 0 END) * 0.01 AS "vendor costs"

FROM public.leads_prod lp
  INNER JOIN public.leads_sold_prod lsp
    ON lp."leadID" = lsp."leadID"
  INNER JOIN public.agents_prod ap
    ON lsp."agentID" = ap."agentID"
  INNER JOIN public.price_tiers_prod ptp
    ON lsp."tierID" = ptp."priceTierID"

WHERE DATE_TRUNC('day', lsp."soldDate") >= '2023-11-01' AND DATE_TRUNC('day', lsp."soldDate") < '2023-11-16'

GROUP BY lp."networkID", lp."vendorID", lsp."agentID", ap."email", "tier", lp."leadType", ptp."isCrossNetwork"
ORDER BY COUNT(lsp."leadID") DESC; */