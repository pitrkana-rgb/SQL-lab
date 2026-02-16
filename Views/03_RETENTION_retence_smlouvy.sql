/*
Author: Petr Kana
Purpose: Cancellation (výpovědi/storno) records for SD campaigns
Source: ECE_DWH.DM.SWT_CANCELLATION_DEFENSE_FT
Filters:
  - STATUS_TEXT contains 'vzetím'
  - ZZCC_CANC_REASON_SU in (ZS01, ZS02, ZS03)
  - REP03_HZ_AK_UNIQ = 1
*/

SELECT
    EXT_UI_BW AS ext_ui_bw,
    [PARTNER] AS partner,
    ZZSTART_TIME_GN AS zzstart_time,
    MOVEOUTDATE AS moveout_date,
    STATUS_TEXT AS status_text
FROM [ECE_DWH].[DM].[SWT_CANCELLATION_DEFENSE_FT]
WHERE STATUS_TEXT LIKE '%vzetím%'
  AND ZZCC_CANC_REASON_SU IN ('ZS01','ZS02','ZS03')
  AND REP03_HZ_AK_UNIQ = '1';

/*
Author: Petr Kana
Purpose: Active contracts for SD campaigns
Source: ECE_SANDBOX.SHARED.Retence_Datamart
Filters:
  - FlagVALID = 1
  - ESTATStatusID = E0006
*/

SELECT
    ObchodniPartner AS obchodni_partner,
    SmlouvaISU AS smlouva_isu,
    PredavaciMisto AS predavaci_misto,
    DatumPodpisu AS datum_podpisu,
    VariantaProduktu_NEW AS varianta_produktu,
    ZELENA AS zelena_flag,
    VyseSlevy AS vyse_slevy,
    DruhSlevy AS druh_slevy,
    NPV_SEGMENT_PRED_PODPISEM AS npv_segment_pred_podpisem
FROM [ECE_SANDBOX].[SHARED].[Retence_Datamart]
WHERE FlagVALID = '1'
  AND ESTATStatusID = 'E0006';
