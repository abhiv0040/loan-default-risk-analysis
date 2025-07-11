-- #############################################################
-- Loan Default Risk Analysis Project (Enhanced Final Version)
-- Tools Used: SQLite (DB Browser), Excel/CSV
-- Author: Abhishek Verma
-- Objective: Analyze lending behavior to identify risk patterns and provide actionable insights for loan underwriting, credit policy, and business intelligence.
-- #############################################################

-- STEP 1: CREATING CLEANED TABLE (Removing Nulls in Key Columns)
DROP TABLE IF EXISTS loans_clean;

CREATE TABLE loans_clean AS
SELECT *
FROM loans_data
WHERE loan_amnt IS NOT NULL
  AND loan_status IS NOT NULL
  AND int_rate IS NOT NULL
  AND term IS NOT NULL
  AND annual_inc IS NOT NULL
  AND grade IS NOT NULL
  AND purpose IS NOT NULL
  AND emp_length IS NOT NULL
  AND home_ownership IS NOT NULL
  AND issue_d IS NOT NULL
  AND addr_state IS NOT NULL
  AND revol_util IS NOT NULL
  AND earliest_cr_line IS NOT NULL
  AND id IS NOT NULL
  AND dti IS NOT NULL
  AND application_type IS NOT NULL;

-- STEP 2: CLEAN TERM COLUMN (convert '36 months' -> 36)
ALTER TABLE loans_clean ADD COLUMN term_clean INTEGER;
UPDATE loans_clean
SET term_clean = CAST(REPLACE(term, ' months', '') AS INTEGER);

-- STEP 3: FLAG ZERO INCOME RECORDS
ALTER TABLE loans_clean ADD COLUMN income_flag TEXT;
UPDATE loans_clean
SET income_flag = CASE 
  WHEN annual_inc = 0 THEN 'Zero Income'
  ELSE 'Reported Income'
END;

-- #############################################################
-- BUSINESS QUESTION 1: What is the default rate across different credit grades?
-- Purpose: Understand how default risk varies by credit grade (A–G) to refine risk-based pricing and approval thresholds.
SELECT grade,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100, 2) AS default_rate
FROM loans_clean
GROUP BY grade
ORDER BY grade;

-- BUSINESS QUESTION 2: How does the average interest rate vary across credit grades?
-- Purpose: Validate the relationship between borrower risk level and interest rate through grade-wise pricing.
SELECT grade,
  ROUND(AVG(int_rate), 2) AS avg_int_rate
FROM loans_clean
GROUP BY grade
ORDER BY avg_int_rate DESC;

-- BUSINESS QUESTION 3: Which loan purposes have the highest default rates?
-- Purpose: Identify risky loan objectives (e.g., small business, medical) to help with better screening and loan product design.
SELECT purpose,
  COUNT(*) AS total_loans,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100, 2) AS default_rate
FROM loans_clean
GROUP BY purpose
ORDER BY default_rate DESC;

-- BUSINESS QUESTION 4: Does borrower income level affect default likelihood?
-- Purpose: Segment borrowers by income to assess financial stability and adjust eligibility or pricing policies.
SELECT 
  CASE 
    WHEN annual_inc = 0 THEN 'Zero Income'
    WHEN annual_inc >= 150000 THEN 'Very High Income'
    WHEN annual_inc >= 100000 THEN 'High Income'
    WHEN annual_inc >= 50000 THEN 'Mid Income'
    ELSE 'Low Income'
  END AS income_group,
  COUNT(*) AS borrowers,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)* 100,2) AS default_rate
FROM loans_clean
GROUP BY income_group
ORDER BY default_rate DESC;

-- BUSINESS QUESTION 5: Is there a correlation between loan term and default rate?
-- Purpose: Evaluate whether longer repayment periods contribute to increased credit risk.
SELECT 
  term_clean AS term_months,
  COUNT(*) AS total_loans,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100, 2) AS default_rate
FROM loans_clean
GROUP BY term_clean
ORDER BY term_clean;

-- BUSINESS QUESTION 6: Does higher interest imply higher default risk?
-- Purpose: Analyze interest rate bands to confirm whether higher interest correlates with increased defaults.
SELECT 
  CASE 
    WHEN int_rate < 10 THEN 'Low Interest'
    WHEN int_rate BETWEEN 10 AND 15 THEN 'Medium Interest'
    ELSE 'High Interest'
  END AS interest_band,
  COUNT(*) AS loans,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)* 100,2) AS default_rate
FROM loans_clean
GROUP BY interest_band
ORDER BY interest_band;

-- BUSINESS QUESTION 7: Does length of employment influence default probability?
-- Purpose: Investigate borrower stability and repayment reliability based on job experience.
SELECT emp_length,
  COUNT(*) AS total_borrowers,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)* 100,2) AS default_rate
FROM loans_clean
GROUP BY emp_length
ORDER BY CAST(emp_length AS REAL);

-- BUSINESS QUESTION 8: Does home ownership status affect default rate?
-- Purpose: Evaluate if borrowers with home ownership are more creditworthy.
SELECT home_ownership,
  COUNT(*) AS borrowers,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)* 100,2) AS default_rate
FROM loans_clean
GROUP BY home_ownership
ORDER BY default_rate DESC;

-- BUSINESS QUESTION 9: How does loan size impact default risk?
-- Purpose: Analyze whether smaller or larger loan amounts lead to higher delinquency.
SELECT 
  CASE 
    WHEN loan_amnt <= 5000 THEN 'Small'
    WHEN loan_amnt <= 15000 THEN 'Medium'
    ELSE 'Large'
  END AS loan_size,
  COUNT(*) AS total_loans,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)* 100,2) AS default_rate
FROM loans_clean
GROUP BY loan_size;

-- BUSINESS QUESTION 10: Are there monthly or seasonal trends in loan issuance and defaults?
-- Purpose: Identify patterns related to macroeconomic factors, lending cycles, or seasonal behavior.
SELECT 
  SUBSTR(issue_d, 1, 3) || '-20' || SUBSTR(issue_d, -2) AS issue_month,
  COUNT(*) AS loans_issued,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)* 100,2) AS default_rate
FROM loans_clean
GROUP BY issue_month
ORDER BY issue_month;

-- BUSINESS QUESTION 11: Which states have the highest loan default rates?
-- Purpose: Identify geographic regions that may need more stringent credit policies.
SELECT addr_state,
  COUNT(*) AS total_loans,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)* 100,2) AS default_rate
FROM loans_clean
GROUP BY addr_state
ORDER BY default_rate DESC;

-- BUSINESS QUESTION 12: Does revolving credit utilization indicate financial stress?
-- Purpose: Use utilization rates as a proxy for borrower liquidity pressure.
SELECT 
  CASE 
    WHEN revol_util < 30 THEN 'Low Utilization'
    WHEN revol_util BETWEEN 30 AND 60 THEN 'Moderate Utilization'
    ELSE 'High Utilization'
  END AS utilization_band,
  COUNT(*) AS borrowers,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)*100, 2) AS default_rate
FROM loans_clean
GROUP BY utilization_band
ORDER BY default_rate DESC;

-- BUSINESS QUESTION 13: How does age of credit history affect default rates?
-- Purpose: Determine if longer credit history reduces borrower risk.
SELECT 
  (CAST(SUBSTR(issue_d, -2) AS INTEGER) + 2000) - 
  (CASE WHEN CAST(SUBSTR(earliest_cr_line, -2) AS INTEGER) > 30 THEN CAST('19' || SUBSTR(earliest_cr_line, -2) AS INTEGER)
        ELSE CAST('20' || SUBSTR(earliest_cr_line, -2) AS INTEGER)
  END) AS credit_age_years,
  COUNT(*) AS borrowers,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)*100, 2) AS default_rate
FROM loans_clean
GROUP BY credit_age_years
ORDER BY credit_age_years DESC;

-- GROUPING CREDIT AGE INTO DETAILED BUCKETS TO ANALYZE DEFAULT RATE TRENDS
SELECT 
  CASE 
    WHEN credit_age_years < 10 THEN '<10 years'
    WHEN credit_age_years BETWEEN 10 AND 19 THEN '10–20 years'
    WHEN credit_age_years BETWEEN 20 AND 29 THEN '20–30 years'
    WHEN credit_age_years BETWEEN 30 AND 39 THEN '30–40 years'
    WHEN credit_age_years BETWEEN 40 AND 49 THEN '40–50 years'
    ELSE '>50 years'
  END AS credit_age_group,
  COUNT(*) AS borrowers,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100, 2) AS default_rate
FROM (
  SELECT 
    (CAST(SUBSTR(issue_d, -2) AS INTEGER) + 2000) - 
    (CASE 
       WHEN CAST(SUBSTR(earliest_cr_line, -2) AS INTEGER) > 30 
         THEN CAST('19' || SUBSTR(earliest_cr_line, -2) AS INTEGER)
       ELSE CAST('20' || SUBSTR(earliest_cr_line, -2) AS INTEGER)
     END) AS credit_age_years,
    loan_status
  FROM loans_clean
  WHERE issue_d IS NOT NULL AND earliest_cr_line IS NOT NULL
) AS derived
GROUP BY credit_age_group
ORDER BY credit_age_group;

-- BUSINESS QUESTION 14: Who are the top 10 borrowers by loan amount?
-- Purpose: Pinpoint large individual exposures to assess high-value loan risks.
SELECT id, loan_amnt, annual_inc,
  RANK() OVER (ORDER BY loan_amnt DESC) AS loan_rank
FROM loans_clean
LIMIT 10;

-- BUSINESS QUESTION 15: Does DTI level correlate with loan default?
-- Purpose: Analyze whether borrowers with high debt-to-income ratios are more likely to default.
SELECT 
  CASE 
    WHEN dti < 10 THEN 'Low DTI'
    WHEN dti BETWEEN 10 AND 20 THEN 'Moderate DTI'
    ELSE 'High DTI'
  END AS dti_band,
  COUNT(*) AS loans,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)*100, 2) AS default_rate
FROM loans_clean
GROUP BY dti_band
ORDER BY dti_band;

-- BUSINESS QUESTION 16: How does application type (individual vs joint) affect default rate?
-- Purpose: Compare behavior of solo applicants versus joint applications to improve underwriting decisions.
SELECT application_type,
  COUNT(*) AS total_loans,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)*100, 2) AS default_rate
FROM loans_clean
GROUP BY application_type;
