SELECT ptp."networkID", ptp."name", lp."layerID",
        CASE WHEN ldp."ageInt" >= 18 AND ldp."ageInt" <= 35 THEN '18 to 35'
            WHEN ldp."ageInt" >= 36 AND ldp."ageInt" <= 55 THEN '36 to 55'
            WHEN ldp."ageInt" >= 56 AND ldp."ageInt" <= 75 THEN '56 to 75'
            WHEN ldp."ageInt" >= 76 AND ldp."ageInt" <= 95 THEN '76 to 95'
            WHEN ldp."ageInt" >= 96 THEN '96+' END AS "ageRange",
       CASE WHEN ldp."incomeInt" >= 0 AND ldp."incomeInt" <= 40000 THEN '0 to 40,000'
            WHEN ldp."incomeInt" >= 40001 AND ldp."incomeInt" <= 80000 THEN '40,000 to 80,000'
            WHEN ldp."incomeInt" >= 80001 AND ldp."incomeInt" <= 250000 THEN '80,000 to 250,000'
            WHEN ldp."incomeInt" >= 250001 AND ldp."incomeInt" <= 500000 THEN '250,000 to 500,000'
            WHEN ldp."incomeInt" >= 500001 AND ldp."incomeInt" <= 1000000 THEN '500,000 to 1,000,000'
            WHEN ldp."incomeInt" >= 1000001 THEN '1,000,000+' END                                                                                                                      AS "incomeRange",
       CASE WHEN ldp."householdInt" >= 1 AND ldp."householdInt" <= 3 THEN '1 to 3'
            WHEN ldp."householdInt" >= 4 AND ldp."householdInt" <= 6 THEN '4 to 6'
            WHEN ldp."householdInt" >= 7 AND ldp."householdInt" <= 10 THEN '7 to 10'
            WHEN ldp."householdInt" >= 10 THEN '10+' END                                                                                                                               AS "householdRange",
       AVG(lsp."price" * 0.01)                                                                                                                                                         AS "avgLeadPrice", AVG(lp."buyerPrice" * 0.01) AS "avgBuyerPrice",
       SUM(CASE WHEN lsp."submittedApplication" = true OR lc."conversion" = true OR lc."crmSold" = true OR lc."submittedApp" = true OR cr."usha_leadid" IS NOT NULL THEN 1 ELSE 0 END) AS "submitted",
       AVG(coalesce(cr."submitted_total_annual_value", lsp."submittedAnnual"))                                                                                                         AS "av",
       SUM(lsp."price" * 0.01)                                                                                                                                                         AS "sumLeadPrice", SUM(lp."buyerPrice" * 0.01) AS "sumBuyerPrice",
       SUM(CASE WHEN lp."leadID" IS NOT NULL THEN 1 ELSE 0 END)                                                                                                                        AS "total leads"
FROM public.leads_sold_prod lsp
    INNER JOIN public.leads_prod lp
    ON lp."leadID" = lsp."leadID"
    INNER JOIN public.price_tiers_prod ptp
    ON lsp."tierID" = ptp."priceTierID"
  INNER JOIN public.leads_demographics_prod ldp
    ON lsp."leadID" = ldp."leadID"
    LEFT JOIN public.conversion_reports cr
    ON lp."corpLeadID" = cr."usha_leadid"
  LEFT JOIN public.lead_conversions lc
    ON lsp."leadID" = lc."leadID"
WHERE lp."networkID" IN ('1fd7e926-574e-4e28-900a-c0f09af004ee', '187bf812-09e0-4a6a-b762-f80b93cadc62', '1d485dd6-3d27-4a9d-99b2-c7dfe6789874', '2af2616d-1878-447f-b88d-f999325d0827')
  AND DATE(lsp."soldDate") >= DATE(NOW()) - INTERVAL '60 days'
  AND DATE(lsp."soldDate") <= DATE(NOW()) - INTERVAL '14 days'
  AND lsp."agentID" IS NOT NULL
GROUP BY ptp."networkID", ptp."name", lp."layerID", "ageRange", "incomeRange", "householdRange";