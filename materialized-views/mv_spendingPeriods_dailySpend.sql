CREATE MATERIALIZED VIEW mv_spendingPeriods_dailySpend AS
SELECT "spendingPeriodID", SUM("price" * 0.01) AS "spend"
FROM public.leads_sold_prod
WHERE DATE("soldDate") = DATE(NOW())
GROUP BY "spendingPeriodID";
