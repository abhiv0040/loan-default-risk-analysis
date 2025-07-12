# 📉 Loan Default Risk Analysis  
**Author:** Abhishek Verma  
**Location:** Chicago, IL  
**Date:** July 2025  

---

## 🧠 Overview  
This project performs a deep-dive analysis of consumer loan data from Lending Club to uncover patterns associated with **loan defaults**. Using SQL (via SQLite), we evaluate over **1,000,000** loan records from **2007 to 2018** to identify borrower risk segments and generate actionable insights that can improve **loan underwriting**, **credit policy**, and **business strategy**.

The objective is to derive practical takeaways on **which borrower attributes are high-risk**, how they correlate with **default behavior**, and what interventions lenders can apply to reduce credit losses.

---

## 📂 Project Files  

| File Name                     | Description                                                                       |
|------------------------------|-----------------------------------------------------------------------------------|
| `loan_default_risk_analysis.sql` | Full SQL script with data cleaning, transformations, and 16 analytical queries    |
| `Loan_Risk_Presentation.pdf`     | Creative presentation summarizing insights, visualizations, and recommendations  |
| `README.md`                  | Project overview and documentation (this file)                                    |

> 📌 **Data Source**:  
> This project uses publicly available data from **[Kaggle – Lending Club Loan Data (2007–2018)](https://www.kaggle.com/datasets/wordsforthewise/lending-club)**

---

## 🎯 Objective  

- Identify **key risk segments** among loan applicants  
- Understand **default trends** across different borrower demographics and loan characteristics  
- Support **data-driven lending decisions** through structured SQL analysis  

---

## 🔍 Business Questions Answered  

1. What is the **default rate by credit grade (A–G)?**  
2. Are **interest rates aligned** with credit risk (i.e., is pricing justified)?  
3. Which **loan purposes** (e.g., small business, medical) are riskier?  
4. How does **income level** affect default rate?  
5. Is **loan term (36 vs 60 months)** associated with higher default?  
6. Do **interest rate bands** (low/medium/high) predict risk?  
7. What is the relationship between **employment length** and default?  
8. How does **home ownership status** impact repayment behavior?  
9. Are **larger loans** riskier than smaller ones?  
10. Are there **seasonal or economic trends** in defaults by issue month/year?  
11. Which **states** show higher concentrations of risky borrowers?  
12. Does **revolving credit utilization** impact default risk?  
13. What is the role of **credit history age** in default prediction?  
14. Who are the **top 10 high exposure borrowers**?  
15. How does **Debt-to-Income (DTI)** ratio relate to default?  
16. Are **joint applications** safer than individual ones?

---

## 📊 Key Findings  

| Metric                | Key Insight                                                   |
|-----------------------|---------------------------------------------------------------|
| Credit Grade          | Defaults increase from **3.27% (A)** to **38.1% (G)**         |
| Interest Rate         | Risk-based pricing is confirmed; avg. rates rise with grade   |
| Loan Purpose          | **Small business** loans are riskiest (**17.95%**)            |
| Income Group          | **Low-income** borrowers show 14.24% default rate             |
| Term Length           | 60-month loans default more (**16.35%**) than 36-month loans  |
| Utilization Rate      | **High utilization** users default at 13.96%                  |
| Employment Length     | 1–2 years and <1 year show higher risk                        |
| Home Ownership        | **Mortgage holders** are less likely to default               |
| State Trends          | **AR, AL, SD** show highest state-level default rates         |
| Credit History        | Shorter history (≤5 years) has higher default probability     |
| Application Type      | **Joint apps** have far lower risk (**5.37%**)                |

---

## 🧠 Recommendations  

- **Tighten Lending Standards** for grades E–G and small business loans  
- Apply **loan size and term-based risk premiums**  
- Target **low-utilization and high-income borrowers** to lower risk pool  
- Consider **credit history age** and **employment length** as credit filters  
- Encourage **joint applications** when possible  
- Implement **state-specific strategies** for high-risk regions  

---

## 🛠 Tools Used  

| Tool        | Purpose                            |
|-------------|------------------------------------|
| SQLite      | SQL querying and transformation     |
| Excel       | Data pre-cleaning                   |
| DB Browser  | SQL development and execution       |
| GitHub      | Project versioning and sharing      |
| Canva       | Presentation and storytelling       |

---

## 📈 Dataset Summary  

| Feature              | Description                            |
|----------------------|----------------------------------------|
| Records Analyzed     | **1,000,000+**                          |
| Loan Amount Range    | **$1,000 – $40,000**                   |
| Interest Rate Range  | **~5% – 30%**                          |
| States Covered       | **All 50 U.S. states**                 |
| Time Period          | **2007–2018 (based on `issue_d`)**     |

---

## 🖼️ Visual Presentation  
For a visual summary with charts and insight-driven storytelling, view the presentation:  
📌 **[Loan Risk Presentation (PDF)](Insert-PDF-Link-Here)**

---

## 📬 Contact  
**Abhishek Verma**  
📌 *MS in Business Analytics | DePaul University*  
📧 Email: abhiv0040@gmail.com  
🔗 LinkedIn: [linkedin.com/in/averma2025](https://linkedin.com/in/averma2025)

---

> _“Data beats opinion. This analysis demonstrates how structured SQL can surface high-risk loan segments and optimize credit policy decisions.”_
