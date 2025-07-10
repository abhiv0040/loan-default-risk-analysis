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
-- BUSINESS QUESTION 1: Default Rate by Credit Grade
-- Purpose: Understanding risk associated with credit grades (A–G)
SELECT grade,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100, 2) AS default_rate
FROM loans_clean
GROUP BY grade
ORDER BY grade;

-- BUSINESS QUESTION 2: Average Interest Rate by Credit Grade
-- Purpose: Validate risk-based pricing; higher grade should imply lower rate
SELECT grade,
  ROUND(AVG(int_rate), 2) AS avg_int_rate
FROM loans_clean
GROUP BY grade
ORDER BY avg_int_rate DESC;

-- BUSINESS QUESTION 3: Default Rate by Loan Purpose
-- Purpose: Spot high-risk purposes (e.g., small business, medical)
SELECT purpose,
  COUNT(*) AS total_loans,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100, 2) AS default_rate
FROM loans_clean
GROUP BY purpose
ORDER BY default_rate DESC;

-- BUSINESS QUESTION 4: Default Rate by Income Group
-- Purpose: Identify how income levels impact default risk
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

-- BUSINESS QUESTION 5: Default Rate by Loan Term
-- Purpose: Determine whether longer repayment periods carry more risk
SELECT 
  term_clean AS term_months,
  COUNT(*) AS total_loans,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100, 2) AS default_rate
FROM loans_clean
GROUP BY term_clean
ORDER BY term_clean;

-- BUSINESS QUESTION 6: Default Rate by Interest Rate Band
-- Purpose: Check if higher interest rates correlate with increased default risk
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

-- BUSINESS QUESTION 7: Employment Length and Default Risk
-- Purpose: Measure impact of work stability on repayment
SELECT emp_length,
  COUNT(*) AS total_borrowers,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)* 100,2) AS default_rate
FROM loans_clean
WHERE emp_length IS NOT NULL
GROUP BY emp_length
ORDER BY CAST(emp_length AS REAL);

-- BUSINESS QUESTION 8: Home Ownership and Default Behavior
-- Purpose: Do homeowners default less often?
SELECT home_ownership,
  COUNT(*) AS borrowers,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)* 100,2) AS default_rate
FROM loans_clean
GROUP BY home_ownership
ORDER BY default_rate DESC;

-- BUSINESS QUESTION 9: Loan Size Categories and Risk
-- Purpose: Understand risk across different loan sizes
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

-- BUSINESS QUESTION 10: Loan Issuance and Default Trends by Month
-- Purpose: Discover seasonal trends or economic shocks (e.g., COVID-19)
SELECT 
  SUBSTR(issue_d, 1, 3) || '-20' || SUBSTR(issue_d, -2) AS issue_month,
  COUNT(*) AS loans_issued,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)* 100,2) AS default_rate
FROM loans_clean
WHERE issue_d IS NOT NULL
GROUP BY issue_month
ORDER BY issue_month;

-- BUSINESS QUESTION 11: State-wise Loan Default Rate
-- Purpose: Identify geographic concentration of risk
SELECT addr_state,
  COUNT(*) AS total_loans,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)* 100,2) AS default_rate
FROM loans_clean
GROUP BY addr_state
ORDER BY default_rate DESC;

-- BUSINESS QUESTION 12: Revolving Utilization Band vs Default
-- Purpose: Financial stress indicator
SELECT 
  CASE 
    WHEN revol_util < 30 THEN 'Low Utilization'
    WHEN revol_util BETWEEN 30 AND 60 THEN 'Moderate Utilization'
    ELSE 'High Utilization'
  END AS utilization_band,
  COUNT(*) AS borrowers,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)*100, 2) AS default_rate
FROM loans_clean
WHERE revol_util IS NOT NULL
GROUP BY utilization_band
ORDER BY default_rate DESC;

-- BUSINESS QUESTION 13: Credit History Age vs Default
-- Purpose: Assess default probability based on borrower credit age
SELECT 
  (CAST(SUBSTR(issue_d, -2) AS INTEGER) + 2000) - 
  (CASE WHEN CAST(SUBSTR(earliest_cr_line, -2) AS INTEGER) > 30 THEN CAST('19' || SUBSTR(earliest_cr_line, -2) AS INTEGER)
        ELSE CAST('20' || SUBSTR(earliest_cr_line, -2) AS INTEGER)
  END) AS credit_age_years,
  COUNT(*) AS borrowers,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)*100, 2) AS default_rate
FROM loans_clean
WHERE issue_d IS NOT NULL AND earliest_cr_line IS NOT NULL
GROUP BY credit_age_years
ORDER BY credit_age_years DESC;

-- BUSINESS QUESTION 14: Top 10 High Exposure Loans
-- Purpose: Identify individual high-risk exposures
SELECT id, loan_amnt, annual_inc,
  RANK() OVER (ORDER BY loan_amnt DESC) AS loan_rank
FROM loans_clean
LIMIT 10;

-- BUSINESS QUESTION 15: DTI Band vs Default Rate
-- Purpose: Compare over-leveraged borrowers vs default tendency
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

-- BUSINESS QUESTION 16: Application Type and Default Rate
-- Purpose: Assess behavior of joint applications
SELECT application_type,
  COUNT(*) AS total_loans,
  ROUND(AVG(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)*100, 2) AS default_rate
FROM loans_clean
GROUP BY application_type;