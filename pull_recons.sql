-- if not in Daylight Savings + INTERVAL '4 hours'
-- data pulls back from 1/1/2023
-- soldDate is based on UTC time
SELECT "networkID"
FROM sara_recons
WHERE "soldDates" >= '2023-11-01'::timestamp + INTERVAL '5 hours' AND "soldDates" <= '2023-11-16'::timestamp + INTERVAL '5 hours'
    --AND "networkID" = 'paste in network id here'
;