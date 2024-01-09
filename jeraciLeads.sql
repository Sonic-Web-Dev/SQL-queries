SELECT lp."vendorID", DATE(lp."created") AS "firstEnteredSystemDate", lp."buyerPrice" * 0.01 AS "buyerPriceDollars", lsp."mpVendorCampaignID", lp."vendorPubID",
       lp."vendorSubID", lp."vendorLandingPage", lp."layerID", ptp."name" AS "tier", DATE(lsp."soldDate") AS "agentPurchasedDate", lsp."price" * 0.01 AS "agentPrice",
       "crmLastResultcode", rrp."lastResult" AS "ringyResultCode", "crmActivityCount", CASE WHEN lsp."submittedApplication" = true OR cr."usha_leadid" IS NOT NULL OR lc."conversion" = true OR
        lc."crmSold" = true OR lc."submittedApp" = true THEN TRUE ELSE FALSE END AS "converted", CONCAT("firstName", ' ', "lastName") AS "purchasingAgent",
        ldp."incomeInt" AS "leadsIncome", ldp."ageInt" AS "leadsAge", ldp."householdInt" AS "householdSize", ldp."region", lep."email"

FROM leads_prod lp
    INNER JOIN leads_sold_prod lsp
    ON lp."leadID" = lsp."leadID"
    INNER JOIN price_tiers_prod ptp
    ON lsp."tierID" = ptp."priceTierID"
    INNER JOIN leads_demographics_prod ldp
    ON lp."leadID" = ldp."leadID"
    LEFT JOIN lead_conversions lc
    ON lp."leadID" = lc."leadID"
    LEFT JOIN conversion_reports cr
    ON lp."corpLeadID" = cr."usha_leadid"
    INNER JOIN agents_prod ap
    ON lsp."agentID" = ap."agentID"
    LEFT JOIN leads_email_prod lep
    ON lp."leadID" = lep."leadID"
    LEFT JOIN ringy_results_prod rrp
    ON lsp."leadID" = rrp."leadId"

WHERE lp."networkID" = 'efce69f6-1775-4ffa-ac72-d0df9d47a361'
    AND LOWER(lp."vendorID") LIKE '%healthcare%'
    AND DATE(lp."created") >= '2023-12-01';
