/*
Author: Petr Kana
Purpose:
  - Service contract events for selected sales channels
  - Filter specific process types (S1, S3, R1, R2, R3, S4)
  - From 2025-01-01 onwards

Source tables:
  - ECE_DWH.DM.CONTRACT_DATAMART
  - ECE_DWH.DW.CRM_SERVICE_CONTRACT_DT
*/

SELECT DISTINCT
    s.ITEM_CREATED_AT AS created_date,
    c.SmlouvaISU AS isu_contract_id,
    c.ObchodniPartner AS business_partner,
    c.SmlouvaCRM AS crm_contract_id,
    c.VariantaProduktuID AS product_variant_id,
    c.VariantaProduktu AS product_variant,
    c.TypProduktu AS product_type,
    c.VariantaProduktuStandardni AS standard_product_variant,
    c.ProdejniKanal AS sales_channel,
    s.PROCESS_TEXT AS process_description
FROM [ECE_DWH].[DM].[CONTRACT_DATAMART] c
JOIN [ECE_DWH].[DW].[CRM_SERVICE_CONTRACT_DT] s
    ON c.SmlouvaISU = s.ISU_CONTR

WHERE c.ProdejniKanalID IN ('PCBR', 'PCCB')
  AND s.PROCESS IN ('S1', 'S3', 'R1', 'R2', 'R3', 'S4')
  AND s.ITEM_CREATED_AT >= '2025-01-01'

ORDER BY created_date DESC;
