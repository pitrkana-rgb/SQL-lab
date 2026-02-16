/*
Author: Petr Kana
Purpose:
  - Latest record per SESSIONID (MAX COUNTER)
  - Department = 2 (ZL)
  - Channel = Email (COMMUNICATIONCHANNELTYPEID = 1)
  - Exclude campaign 587 (IOE)

Source tables:
  - ECE_DWH.PER.JFP_SESSION
  - ECE_DWH.DM_NPV.API_NPV_JFP_INIT_V
*/

SELECT
    s.SESSIONID AS session_id,
    s.[COUNTER] AS step_counter,
    s.CAMPAIGNNAME AS campaign_name,
    s.COMMUNICATIONAGEINHOURS AS communication_age_hours,
    s.CREATEDNOTIME AS created_datetime,
    s.USERKIDID AS user_kid,
    s.USERDEPARTMENTNAME AS department_name,
    s.USERTEAMNAME AS team_name,
    s.CUSTOMEROP AS business_partner,
    s.CUSTOMEREANEIC AS supply_point,
    s.SESSIONGLOBALSTATUSNAME AS global_status,
    npv.Value1 AS npv_segment
FROM [ECE_DWH].[PER].[JFP_SESSION] s

JOIN (
    SELECT 
        SESSIONID, 
        MAX([COUNTER]) AS max_counter
    FROM [ECE_DWH].[PER].[JFP_SESSION]
    GROUP BY SESSIONID
) max_records
    ON s.SESSIONID = max_records.SESSIONID
   AND s.[COUNTER] = max_records.max_counter

JOIN [ECE_DWH].[DM_NPV].[API_NPV_JFP_INIT_V] npv
    ON s.CUSTOMEROP = npv.BUSINESSPARTNER

WHERE s.USERDEPARTMENTID = '2'
  AND s.COMMUNICATIONCHANNELTYPEID = '1'
  AND s.CAMPAIGNID <> '587'

ORDER BY s.CREATEDNOTIME DESC;
