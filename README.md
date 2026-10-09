# UPI-Digital-Payments-Analytics-Capstone
End-to-end UPI payments analytics: Excel, SQL, Python EDA, Statistical testing, Power BI dashboards &amp; fraud-risk investigation.

**Author:** Kaustubh Sinha  
**Stack:** MySQL · Python (Pandas, SciPy, Plotly) · Power BI · Excel  
**Scale:** 100,000 transactions · 7 relational tables · 20 DAX measures · 7 Power BI pages  

![Fraud Rate by Root Status](06_Executive_Report/images/fraud_by_root.png)

## 🎯 Headline Findings
- **Rooted devices:** 20.69% fraud rate vs **1.39%** for non-rooted → **19.30 pp gap** (statistically significant).
- **Merchant type:** No significant fraud-rate differences (ANOVA p = 0.686, η² = 0.006).
- **Operational baseline:** 92.14% success · 5.87% failure · 1.99% pending · 1.45% reversal.

## 📁 Repository Structure
(link to each folder with one-line descriptions)

## 🔍 Investigation Workflow
Signal → Segment → Drill Through → Investigate → Act

## 📊 Deliverables
- [Executive Report](06_Executive_Report/UPI_Executive_Report.pdf)
- [Power BI Dashboard](05_Power_BI/UPI_Transaction_Analytics.pbix)
- [Python Notebook](04_Python/UPI_Transaction_Analysis.ipynb)
- [SQL Schema & Queries](03_SQL/)
- [3D Visualizations](04_Python/3D_Visualizations/)
- [Business Planning Deck](01_Business_Understanding/)


## 📦 Dataset & External Assets

The full validated dataset and large media files are hosted externally due to GitHub's file size limits.

| Asset | Size | Link |
|---|---|---|
| Validated Excel Workbook (`UPI_cleaned_KS.xlsx`) | ~XXX MB | [Download from Google Drive]: https://drive.google.com/drive/folders/1tUMbA_UdjGGiG_YGN1KB_bCGyVwcDJq-?usp=drive_link |
| 3D Visualization Videos (full resolution) | ~XXX MB | [Watch on Google Drive] https://drive.google.com/file/d/1gSklFyZNE_wzfjvaarWhDV_RJAPKPH33/view?usp=drive_link |  https://drive.google.com/file/d/1M-ySZmWKVO1YMDtEKOM5C5rGVZIE_2L9/view?usp=drive_link


upi-digital-payments-analytics/
├── 01_Business_Understanding/
│   └── UPI_Business_Understanding_Analytical_Planning.pptx
├── 02_Data/
│   ├── Raw_Data/
│   │   ├── customer_master.csv
│   │   ├── device_info.csv
│   │   ├── upi_account_details.csv
│   │   ├── merchant_info.csv
│   │   ├── upi_transaction_history.csv
│   │   ├── customer_feedback_surveys.csv
│   │   └── fraud_alert_history.csv
│   ├── Validated_Data/
│   │   └── Data Quality Log.csv
│   └── (large Excel file NOT uploaded — link in README)
├── 03_SQL/
│   ├── UPI_Analytics_Schema.sql
│   └── UPI_Analytics_Analysis_Queries.sql
├── 04_Python/
│   ├── UPI_Transaction_Analysis.ipynb
│   └── 3D_Visualizations/
│       ├── video1_compressed.mp4
│       └── video2_compressed.mp4
├── 05_Power_BI/
│   └── UPI_Transaction_Analytics.pbix
├── 06_Executive_Report/
│   ├── UPI_Executive_Report.pdf
│   └── UPI_Executive_Report.docx
├── 07_Project_Documentation/
│   ├── UPI_Project_Instructions.pdf
│   └── README.md  ← rename your README.pdf content
└── README.md      ← root-level, goes at top of repo
