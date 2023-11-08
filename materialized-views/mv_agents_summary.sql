CREATE MATERIALIZED VIEW mv_agents_summary AS 
SELECT mp."managerID",
       CONCAT(ap."firstName", ' ', ap."lastName") AS "agentName",
       ap."agentID",
       ap.email,
       SUM(abl.amount)::numeric * 0.01 AS "agentBalance"
FROM agents_prod ap
         LEFT JOIN managers_prod mp ON ap."agentID"::text = mp."agentID"::text
         LEFT JOIN agent_balances_legacy abl ON ap."agentID"::text = abl."agentID"::text
GROUP BY mp."managerID", (concat(ap."firstName", ' ', ap."lastName")), ap."agentID", ap.email;
