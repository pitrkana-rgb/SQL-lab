/*
Author: Petr Kana
Purpose:
  - Link cancellations with retention calls (before/after)
  - Deduplicate per SWITCHNUM
  - Calculate KPI:
      • Kontakt před výpovědí
      • Storno po retenčním hovoru

Source tables:
  - ECE_DWH.DM.SWT_CANCELLATION_FT
  - ECE_SANDBOX.SHARED.RETENCNI_HOVORY_polozkove_V
*/

DROP TABLE IF EXISTS #vypoved_hovor;
DROP TABLE IF EXISTS #duplicitni_hovory;
DROP TABLE IF EXISTS #base;

-- Base cancellation + retention linkage
SELECT DISTINCT
       a.REP_HZ_AK_UNIQUE              AS uniq_prij,
       a.REP03_HZ_AK_UNIQ              AS uniq_ucin,
       a.EXT_UI_BW                     AS predavaci_misto,
       a.SPARTE_TEXT                   AS komodita,
       a.PARTNER                       AS business_partner,
       a.STATUS_TEXT                   AS status_vypovedi,
       a.ZZSTART_TIME_GN               AS start_date,
       a.MOVEOUTDATE                   AS moveout_date,
       a.ZZCC_CANC_REASON_SU           AS cancel_reason_id,
       a.ZZCC_CANC_REASON_SU_TEXT      AS cancel_reason,
       a.SWITCHNUM                     AS switch_number,
       ISNULL(r_pred.flag_partneru_ret_call,0) AS flag_ret_call_pred,
       ISNULL(r_po.flag_partneru_ret_call,0)   AS flag_ret_call_po,
       a.AEDAT                         AS status_change_date,

       CASE 
            WHEN r_po.flag_partneru_ret_call IS NULL THEN NULL
            WHEN a.AEDAT >= r_po.creatednotime 
                 AND a.STATUS IN ('ZZ','ZK')
                 AND DATEDIFF(DAY, r_po.creatednotime, a.AEDAT) <= 10
                 THEN N'Stornovaná do 10 dnů po RET hovoru'
            WHEN a.AEDAT < r_po.creatednotime 
                 AND a.STATUS IN ('ZZ','ZK')
                 THEN N'Stornováno před RET hovorem'
            WHEN r_po.creatednotime >= a.ZZSTART_TIME_GN
                 THEN N'Nestornovaná do 10 dnů po RET hovoru'
            ELSE N'Ostatní'
       END AS flag_storno_po_volani

INTO #vypoved_hovor

FROM [ECE_DWH].[DM].[SWT_CANCELLATION_FT] a

LEFT JOIN (
    SELECT
        CUSTOMEROP,
        CREATEDNOTIME,
        COUNT(DISTINCT CUSTOMEROP) AS flag_partneru_ret_call
    FROM ECE_SANDBOX.SHARED.RETENCNI_HOVORY_polozkove_V
    WHERE DEPARTMENT IN (N'Zákaznická linka', N'Atoda')
    GROUP BY CUSTOMEROP, CREATEDNOTIME
) r_pred
    ON a.PARTNER = r_pred.CUSTOMEROP
   AND r_pred.CREATEDNOTIME BETWEEN DATEADD(MONTH, -3, a.ZZSTART_TIME_GN)
                                AND a.ZZSTART_TIME_GN

LEFT JOIN (
    SELECT
        CUSTOMEROP,
        CREATEDNOTIME,
        COUNT(DISTINCT CUSTOMEROP) AS flag_partneru_ret_call
    FROM ECE_SANDBOX.SHARED.RETENCNI_HOVORY_polozkove_V
    WHERE DEPARTMENT IN (N'Zákaznická linka', N'Atoda')
      AND CONTACT_SUBCATEGORY_NAME LIKE '%SD -%'
    GROUP BY CUSTOMEROP, CREATEDNOTIME
) r_po
    ON a.PARTNER = r_po.CUSTOMEROP
   AND r_po.CREATEDNOTIME >= a.ZZSTART_TIME_GN
   AND r_po.CREATEDNOTIME < a.MOVEOUTDATE

WHERE a.REP_HZ_AK_UNIQUE = 1
  AND a.ZZCC_CANC_REASON_SU IN ('ZS01','ZS02','ZS03');


-- Deduplication
SELECT *,
       ROW_NUMBER() OVER (
            PARTITION BY switch_number
            ORDER BY 
                CASE 
                    WHEN flag_storno_po_volani IS NULL THEN 1
                    WHEN flag_storno_po_volani = N'Stornovaná do 10 dnů po RET hovoru' THEN 2
                    WHEN flag_storno_po_volani = N'Stornováno před RET hovorem' THEN 3
                    WHEN flag_storno_po_volani = N'Nestornovaná do 10 dnů po RET hovoru' THEN 4
                    ELSE 99
                END
       ) AS row_number
INTO #duplicitni_hovory
FROM #vypoved_hovor;

SELECT *
INTO #base
FROM #duplicitni_hovory
WHERE row_number = 1;


-- KPI: Kontakt před výpovědí
SELECT 
    YEAR(start_date) AS rok,
    MONTH(start_date) AS mesic,
    COUNT(predavaci_misto) AS pocet_vypovedi,
    SUM(flag_ret_call_pred) AS retencni_hovory_pred,
    CAST(SUM(flag_ret_call_pred) AS DECIMAL(10,2))
    / NULLIF(COUNT(predavaci_misto),0) AS kpi_kontakt_pred_vypovedi
FROM #base
WHERE YEAR(start_date) = 2025
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY 1,2;


-- KPI: Storno po retenčním hovoru
SELECT 
    YEAR(moveout_date) AS rok,
    MONTH(moveout_date) AS mesic,
    CAST(
        SUM(CASE 
                WHEN flag_storno_po_volani = N'Stornovaná do 10 dnů po RET hovoru'
                THEN 1 ELSE 0 END
        ) AS DECIMAL(10,2)
    )
    / NULLIF(COUNT(predavaci_misto),0) AS kpi_storno_po_ret
FROM #base
WHERE YEAR(moveout_date) = 2025
  AND flag_storno_po_volani IN (
        N'Stornovaná do 10 dnů po RET hovoru',
        N'Nestornovaná do 10 dnů po RET hovoru'
  )
GROUP BY YEAR(moveout_date), MONTH(moveout_date)
ORDER BY 1,2;
