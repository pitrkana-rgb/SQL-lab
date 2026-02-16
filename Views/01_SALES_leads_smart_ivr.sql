/*
Author: Pitr Kana
Purpose: Reporting extract - SmartIVR KOMODITA leads
Database: DWH_ECE
Source table: ECE_DWH.DM.C4C_LEADS
*/

SELECT
    CAST(leads.LEAD_CREATED_DATE AS DATE) AS datum,
    leads.LEAD AS lead_id,
    leads.SOURCE_CHANNEL AS zdrojovy_kanal,
    leads.TYP AS typ_leadu,
    leads.SOURCE_SYSTEM AS zdrojovy_system,
    leads.STAGE AS faze_leadu
FROM [ECE_DWH].[DM].[C4C_LEADS] AS leads
WHERE leads.TYP = 'KOMODITA'
  AND leads.SOURCE_SYSTEM = 'SmartIVR'
  AND leads.STAGE = 'C4C_lead'
ORDER BY datum DESC, lead_id;
