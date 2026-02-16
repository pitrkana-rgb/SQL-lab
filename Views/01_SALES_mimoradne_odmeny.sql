/*
Author: Petr Kana
Purpose: List of leads for extra rewards in RC
*/

/*
FVE Aggregated
*/
WITH leads_data AS (
    SELECT 
        c1.*,
        COALESCE(c2.KID_ZADAVATELE, c1.KID_ZADAVATELE) AS kid_final
    FROM [ECE_DWH].[DM].[C4C_LEADS] c1
    LEFT JOIN [ECE_DWH].[DM].[C4C_LEADS] c2
        ON c1.LEAD = c2.LEAD
       AND c2.STAGE = 'C4C_lead'
    WHERE c1.STAGE = 'C4C_oportunity'
      AND c1.TYP = 'SOLUTIONS'
      AND c1.PRODUCT_CATEGORY = 'E.ON Solar'
      AND c1.LEAD_CREATED_DATE >= '2025-03-01'
      AND c1.SOURCE_CHANNEL IN ('Zákaznická linka', 'Poradenské centrum')
)

SELECT
    FORMAT(l.LEAD_CREATED_DATE, 'yyyy-MM') AS month,
    SUBSTRING(h.PERNR, 4, LEN(h.PERNR)) AS personal_id,
    CONCAT(h.NAMEFIRST, ' ', h.NAMELAST) AS full_name,
    h.ORGUNITNAME AS org_unit,
    COUNT(*) AS converted_leads
FROM leads_data l
LEFT JOIN [ECE_DWH].[DW].[HR_ORGCHART_FT] h
    ON l.kid_final = h.KID
WHERE h.VALIDTO = '9999-12-31'
  AND h.ORGUNITID > 0
  AND h.ORGUNITNAME <> 'Obslužné procesy'
GROUP BY
    FORMAT(l.LEAD_CREATED_DATE, 'yyyy-MM'),
    SUBSTRING(h.PERNR, 4, LEN(h.PERNR)),
    CONCAT(h.NAMEFIRST, ' ', h.NAMELAST),
    h.ORGUNITNAME
ORDER BY full_name, month;

/*
FVE Detail
*/
WITH leads_data AS (
    SELECT 
        c1.*,
        COALESCE(c2.KID_ZADAVATELE, c1.KID_ZADAVATELE) AS kid_final
    FROM [ECE_DWH].[DM].[C4C_LEADS] c1
    LEFT JOIN [ECE_DWH].[DM].[C4C_LEADS] c2
        ON c1.LEAD = c2.LEAD
       AND c2.STAGE = 'C4C_lead'
    WHERE c1.STAGE = 'C4C_oportunity'
      AND c1.TYP = 'SOLUTIONS'
      AND c1.PRODUCT_CATEGORY = 'E.ON Solar'
      AND c1.LEAD_CREATED_DATE >= '2025-03-01'
      AND c1.SOURCE_CHANNEL IN ('Zákaznická linka', 'Poradenské centrum')
)

SELECT
    l.LEAD AS lead_id,
    l.LEAD_CREATED_DATE AS created_date,
    FORMAT(l.LEAD_CREATED_DATE, 'yyyy-MM') AS month,
    CONCAT(h.NAMEFIRST, ' ', h.NAMELAST) AS full_name,
    SUBSTRING(h.PERNR, 4, LEN(h.PERNR)) AS personal_id,
    h.ORGUNITNAME AS org_unit
FROM leads_data l
LEFT JOIN [ECE_DWH].[DW].[HR_ORGCHART_FT] h
    ON l.kid_final = h.KID
WHERE h.VALIDTO = '9999-12-31'
  AND h.ORGUNITID > 0
  AND h.ORGUNITNAME <> 'Obslužné procesy'
ORDER BY full_name, month;


/*
TČ Aggregated 
*/
WITH leads_data AS (
    SELECT 
        c1.*,
        COALESCE(c2.KID_ZADAVATELE, c1.KID_ZADAVATELE) AS kid_final
    FROM [ECE_DWH].[DM].[C4C_LEADS] c1
    LEFT JOIN [ECE_DWH].[DM].[C4C_LEADS] c2
        ON c1.LEAD = c2.LEAD
       AND c2.STAGE = 'C4C_lead'
    WHERE c1.STAGE = 'C4C_oportunity'
      AND c1.TYP = 'SOLUTIONS'
      AND c1.PRODUCT = 'Tepelné čerpadlo'
      AND c1.LEAD_CREATED_DATE >= '2025-04-01'
      AND c1.SOURCE_CHANNEL IN ('Zákaznická linka', 'Poradenské centrum')
)

SELECT
    FORMAT(l.LEAD_CREATED_DATE, 'yyyy-MM') AS month,
    SUBSTRING(h.PERNR, 4, LEN(h.PERNR)) AS personal_id,
    CONCAT(h.NAMEFIRST, ' ', h.NAMELAST) AS full_name,
    h.ORGUNITNAME AS org_unit,
    COUNT(*) AS converted_leads
FROM leads_data l
LEFT JOIN [ECE_DWH].[DW].[HR_ORGCHART_FT] h
    ON l.kid_final = h.KID
WHERE h.VALIDTO = '9999-12-31'
  AND h.ORGUNITID > 0
  AND h.ORGUNITNAME <> 'Obslužné procesy'
GROUP BY
    FORMAT(l.LEAD_CREATED_DATE, 'yyyy-MM'),
    SUBSTRING(h.PERNR, 4, LEN(h.PERNR)),
    CONCAT(h.NAMEFIRST, ' ', h.NAMELAST),
    h.ORGUNITNAME
ORDER BY full_name, month;


/*
COMMODITY Detail
*/
SELECT DISTINCT
    lead.LEAD AS lead_id,
    lead.CONTRACT AS contract_id,
    lead.LEAD_CREATED_DATE AS created_date,
    FORMAT(lead.LEAD_CREATED_DATE, 'yyyy-MM') AS created_month,
    CONCAT(hr.NAMEFIRST, ' ', hr.NAMELAST) AS full_name,
    SUBSTRING(hr.PERNR, 4, LEN(hr.PERNR)) AS personal_id,
    hr.ORGUNITNAME AS org_unit
FROM [ECE_DWH].[DM].[C4C_LEADS] lead
LEFT JOIN [ECE_DWH].[DW].[HR_ORGCHART_FT] hr
    ON lead.KID_ZADAVATELE = hr.KID
WHERE lead.STAGE = 'BRUTTO'
  AND lead.TYP = 'KOMODITA'
  AND lead.LEAD_CREATED_DATE >= '2025-04-01'
  AND lead.SOURCE_CHANNEL IN ('Zákaznická linka', 'Poradenské centrum')
  AND lead.KAMPAN NOT LIKE '%Zákazník%'
  AND hr.VALIDTO = '9999-12-31'
  AND hr.ORGUNITID > 0
  AND hr.ORGUNITNAME <> 'Obslužné procesy'
ORDER BY full_name, created_month;


/*
COMMODITY Aggregated
*/
SELECT
    FORMAT(lead.LEAD_CREATED_DATE, 'yyyy-MM') AS month,
    SUBSTRING(hr.PERNR, 4, LEN(hr.PERNR)) AS personal_id,
    CONCAT(hr.NAMEFIRST, ' ', hr.NAMELAST) AS full_name,
    hr.ORGUNITNAME AS org_unit,
    COUNT(DISTINCT lead.CONTRACT) AS contracts
FROM [ECE_DWH].[DM].[C4C_LEADS] lead
LEFT JOIN [ECE_DWH].[DW].[HR_ORGCHART_FT] hr
    ON lead.KID_ZADAVATELE = hr.KID
WHERE lead.STAGE = 'BRUTTO'
  AND lead.TYP = 'KOMODITA'
  AND lead.LEAD_CREATED_DATE >= '2025-04-01'
  AND lead.SOURCE_CHANNEL IN ('Zákaznická linka', 'Poradenské centrum')
  AND lead.KAMPAN NOT LIKE '%Zákazník%'
  AND hr.VALIDTO = '9999-12-31'
  AND hr.ORGUNITID > 0
  AND hr.ORGUNITNAME <> 'Obslužné procesy'
GROUP BY
    FORMAT(lead.LEAD_CREATED_DATE, 'yyyy-MM'),
    SUBSTRING(hr.PERNR, 4, LEN(hr.PERNR)),
    CONCAT(hr.NAMEFIRST, ' ', hr.NAMELAST),
    hr.ORGUNITNAME
ORDER BY full_name, month;
