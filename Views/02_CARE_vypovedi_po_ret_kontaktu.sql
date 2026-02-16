/*
Author: Petr Kana
Purpose:
  - Retention calls (ZL, Atoda)
  - Link to cancellation records (ZS01, ZS02, ZS03)
  - Match calls within 3 months before cancellation start until moveout date

Source tables:
  - ECE_SANDBOX.SHARED.RETENCNI_HOVORY_polozkove_V
  - ECE_DWH.DM.SWT_CANCELLATION_FT
*/

SELECT DISTINCT
    r.CUSTOMEROP AS business_partner,
    r.CallID AS call_id,
    r.SESSIONID AS session_id,
    r.COMMUNICATIONCHANNELTYPENAME AS channel_name,
    r.CREATEDNOTIME AS call_date,
    r.DEPARTMENT AS department,
    r.USERTEAMNAME AS team_name,
    r.NAMEFULL AS consultant_full_name,
    r.CONTACT_SUBCATEGORY_NAME AS contact_subcategory,
    a.STATUS_TEXT AS cancellation_status
FROM ECE_SANDBOX.SHARED.RETENCNI_HOVORY_polozkove_V r

LEFT JOIN [ECE_DWH].[DM].[SWT_CANCELLATION_FT] a
    ON r.CUSTOMEROP = a.PARTNER
   AND r.CREATEDNOTIME BETWEEN DATEADD(MONTH, -3, a.ZZSTART_TIME_GN)
                           AND a.MOVEOUTDATE
   AND a.ZZCC_CANC_REASON_SU IN ('ZS01', 'ZS02', 'ZS03')

WHERE r.DEPARTMENT IN (N'Zákaznická linka', N'Atoda')

ORDER BY call_date DESC;
