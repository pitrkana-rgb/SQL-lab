/*
Author: Petr Kana
Purpose:
  - Service contracts with green energy attribute
  - Only approved records (USER_STATUS = ACCP)
  - Selected process types (ZSP, ZDP, PS)
  - Limited to Zákaznická linka organization

Source tables:
  - ECE_DWH.DW.CRM_SERVICE_CONTRACT_DT
  - ECE_DWH.DW.CRM_PRODUCT_ATTR_DT
  - ECE_DWH.DW.HR_ORGCHART_FT
*/

SELECT
    prod_attr.ATTR_VALUE_TEXT AS green_energy_flag,
    contract.ISU_CONTR AS contract_id,
    contract.ITEM_CREATED_AT AS created_date,
    contract.PROCESS AS process_code,
    contract.PROCESS_TEXT AS process_description,
    contract.CONTRACT_TYPE_TEXT AS contract_type,
    contract.SHORT_TEXT_UC AS contract_description,
    contract.USER_STATUS_TEXT AS status_description,
    contract.ITEM_CREATED_BY AS created_by_kid,
    CONCAT(hr.NAMELAST, ' ', hr.NAMEFIRST) AS author_full_name,
    hr.ORGUNITNAME AS org_unit_name
FROM [ECE_DWH].[DW].[CRM_SERVICE_CONTRACT_DT] contract

LEFT JOIN [ECE_DWH].[DW].[CRM_PRODUCT_ATTR_DT] prod_attr
    ON contract.ITEM_GUID = prod_attr.GUID
   AND prod_attr.ATTR_NAME = 'ZEC_EKO_CHBOX'

LEFT JOIN [ECE_DWH].[DW].[HR_ORGCHART_FT] hr
    ON contract.ITEM_CREATED_BY = hr.KID

WHERE contract.PROCESS IN ('ZSP', 'ZDP', 'PS')
  AND contract.USER_STATUS = 'ACCP'
  AND hr.ORGUNITNAME LIKE '%Zákaznická linka%'
  AND hr.VALIDTO = '9999-12-31'

ORDER BY contract.ITEM_CREATED_AT DESC;
