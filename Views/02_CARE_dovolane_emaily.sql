/*
Author: Petr Kana
Purpose:
  - Daily email performance per consultant (Zákaznická linka)
  - Count distinct email sessions
  - Calculate phone resolution ratio

Filters:
  - USERTEAMNAME contains 'Zákaznická linka'
  - Exclude GDPR users
  - Exclude campaign 25
  - Channel = Email (COMMUNICATIONCHANNELTYPEID = 1)
  - Exclude internal campaigns
*/

SELECT
    s.CREATEDNOTIME AS created_date,
    s.USERKIDID AS user_kid,
    MAX(s.USERTEAMNAME) AS team_name,
    COUNT(DISTINCT s.SESSIONID) AS email_count,
    SUM(CASE WHEN s.SESSIONGLOBALSTATUSID = '797' THEN 1 ELSE 0 END) AS resolved_phone,
    SUM(CASE WHEN s.SESSIONGLOBALSTATUSID = '909' THEN 1 ELSE 0 END) AS resolved_phone_email,
    (
        SUM(CASE WHEN s.SESSIONGLOBALSTATUSID = '797' THEN 1 ELSE 0 END) +
        SUM(CASE WHEN s.SESSIONGLOBALSTATUSID = '909' THEN 1 ELSE 0 END)
    ) * 1.0 / COUNT(DISTINCT s.SESSIONID) AS resolution_ratio
FROM [ECE_DWH].[DW].[JFP_SESSION_V] s

WHERE s.USERTEAMNAME LIKE '%Zákaznická linka%'
  AND s.USERKIDID NOT LIKE '%GDPR%'
  AND s.CAMPAIGNID <> '25'
  AND s.CREATEDNOTIME = '2025-03-06'
  AND s.COMMUNICATIONCHANNELTYPEID = '1'
  AND s.CAMPAIGNORIGNAME NOT IN (
        'Individuální odesílání e-mailu',
        'Interní úkoly'
      )

GROUP BY
    s.USERKIDID,
    s.CREATEDNOTIME

ORDER BY s.CREATEDNOTIME DESC;
