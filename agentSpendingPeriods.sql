SELECT DISTINCT np."networkID",
    spp."spendingPeriodID", asu."agentName", asu."email", cp."fixedCampaignName" AS "Tier", cp."campaignTierID", asu."agentBalance", spp."dailySpendLimit" * 0.01 AS "dailySpendLimit",
    spp."dowSun" AS "Sunday", spp."dowMon" AS "Monday", spp."dowTue" AS "Tuesday", spp."dowWed" AS "Wednesday", spp."dowThu" AS "Thursday", spp."dowFri" AS "Friday",
    spp."dowSat" AS "Saturday", spp."startTime"/60 AS "hoursToStart", spp."endTime"/60 AS "hoursToEnd", spp."paused", spp."throttleLeadsPer"/60 AS "throttlingSeconds",
    spp."throttleNoMoreThan", COALESCE(lsp."spend", 0) AS "spend"
FROM public.mv_networkprice_IDs np
    INNER JOIN public.campaigns_prod cp
        ON np."priceTierID" = cp."campaignTierID"
    INNER JOIN public.campaigns_spending_periods_prod csp
        ON CAST(cp."campaignID" AS uuid) = csp."campaignID"
    INNER JOIN public.spending_periods_prod spp
        ON csp."spendingPeriodID" = spp."spendingPeriodID"
    INNER JOIN public.mv_agents_summary asu
        ON asu."agentID" = cp."agentID"
    LEFT JOIN public.agents_prod ap
        ON asu."managerID" = ap."agentID"
    LEFT JOIN public.mv_spendingPeriods_dailySpend lsp
        ON CAST(lsp."spendingPeriodID" AS uuid) = spp."spendingPeriodID"
WHERE cp."status" = 'active'
  -- if not using liquid filtering, replace "IN ({{ variable }})" with "= variable value"
    AND np."networkID" IN ({{ networkid }})
    AND asu."managerID" IN ({{ managerid }})
    AND spp."paused" IN ({{ paused }})
    AND cp."campaignTierID" IN ({{ tierid }})