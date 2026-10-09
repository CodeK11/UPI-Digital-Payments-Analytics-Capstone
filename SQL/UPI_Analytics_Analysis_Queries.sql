-- UPI Transaction Analytics
-- Analysis and validation queries used to support the project.

USE upi_analytics;

-- 1. Basic row-count validation
SELECT 'customer_master' AS table_name, COUNT(*) AS row_count FROM customer_master
UNION ALL SELECT 'device_info', COUNT(*) FROM device_info
UNION ALL SELECT 'upi_account_details', COUNT(*) FROM upi_account_details
UNION ALL SELECT 'merchant_info', COUNT(*) FROM merchant_info
UNION ALL SELECT 'upi_transaction_history', COUNT(*) FROM upi_transaction_history
UNION ALL SELECT 'customer_feedback_surveys', COUNT(*) FROM customer_feedback_surveys
UNION ALL SELECT 'fraud_alert_history', COUNT(*) FROM fraud_alert_history;

-- 2. Primary-key uniqueness checks
SELECT COUNT(*) AS rows_total, COUNT(DISTINCT customer_id) AS ids_unique FROM customer_master;
SELECT COUNT(*) AS rows_total, COUNT(DISTINCT device_id) AS ids_unique FROM device_info;
SELECT COUNT(*) AS rows_total, COUNT(DISTINCT upi_id) AS ids_unique FROM upi_account_details;
SELECT COUNT(*) AS rows_total, COUNT(DISTINCT merchant_id) AS ids_unique FROM merchant_info;
SELECT COUNT(*) AS rows_total, COUNT(DISTINCT transaction_id) AS ids_unique FROM upi_transaction_history;
SELECT COUNT(*) AS rows_total, COUNT(DISTINCT feedback_id) AS ids_unique FROM customer_feedback_surveys;
SELECT COUNT(*) AS rows_total, COUNT(DISTINCT alert_id) AS ids_unique FROM fraud_alert_history;

-- 3. Core transaction KPIs
SELECT
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_transaction_value,
    AVG(amount) AS average_transaction_amount,
    SUM(status = 'success') AS successful_transactions,
    SUM(status = 'failed') AS failed_transactions,
    SUM(status = 'pending') AS pending_transactions,
    SUM(fraud_flag = TRUE) AS fraud_transactions,
    SUM(reversal_flag = TRUE) AS reversed_transactions
FROM upi_transaction_history;

-- 4. Core transaction rates
SELECT
    ROUND(100 * SUM(status = 'success') / COUNT(*), 2) AS success_rate_pct,
    ROUND(100 * SUM(status = 'failed') / COUNT(*), 2) AS failure_rate_pct,
    ROUND(100 * SUM(fraud_flag = TRUE) / COUNT(*), 2) AS fraud_rate_pct,
    ROUND(100 * SUM(reversal_flag = TRUE) / COUNT(*), 2) AS reversal_rate_pct
FROM upi_transaction_history;

-- 5. Transaction activity by channel
SELECT
    channel,
    COUNT(*) AS transactions,
    SUM(amount) AS transaction_value,
    SUM(fraud_flag = TRUE) AS fraud_transactions,
    ROUND(100 * SUM(fraud_flag = TRUE) / COUNT(*), 2) AS fraud_rate_pct,
    ROUND(100 * SUM(status = 'failed') / COUNT(*), 2) AS failure_rate_pct
FROM upi_transaction_history
GROUP BY channel
ORDER BY transactions DESC;

-- 6. Transaction activity by region
SELECT
    c.region,
    COUNT(*) AS transactions,
    SUM(t.amount) AS transaction_value,
    SUM(t.fraud_flag = TRUE) AS fraud_transactions,
    ROUND(100 * SUM(t.fraud_flag = TRUE) / COUNT(*), 2) AS fraud_rate_pct,
    ROUND(100 * SUM(t.status = 'failed') / COUNT(*), 2) AS failure_rate_pct
FROM upi_transaction_history t
JOIN customer_master c ON c.customer_id = t.customer_id
GROUP BY c.region
ORDER BY transactions DESC;

-- 7. Device-type performance and fraud
SELECT
    d.device_type,
    COUNT(*) AS transactions,
    SUM(t.fraud_flag = TRUE) AS fraud_transactions,
    ROUND(100 * SUM(t.fraud_flag = TRUE) / COUNT(*), 2) AS fraud_rate_pct,
    ROUND(100 * SUM(t.status = 'failed') / COUNT(*), 2) AS failure_rate_pct
FROM upi_transaction_history t
JOIN device_info d ON d.device_id = t.device_id
GROUP BY d.device_type
ORDER BY fraud_rate_pct DESC;

-- 8. Rooted vs non-rooted fraud comparison
SELECT
    d.is_rooted,
    COUNT(*) AS transactions,
    SUM(t.fraud_flag = TRUE) AS fraud_transactions,
    ROUND(100 * SUM(t.fraud_flag = TRUE) / COUNT(*), 4) AS fraud_rate_pct
FROM upi_transaction_history t
JOIN device_info d ON d.device_id = t.device_id
GROUP BY d.is_rooted
ORDER BY d.is_rooted;

-- 9. Merchant-type performance
SELECT
    m.merchant_type,
    COUNT(*) AS transactions,
    SUM(t.amount) AS transaction_value,
    SUM(t.fraud_flag = TRUE) AS fraud_transactions,
    ROUND(100 * SUM(t.fraud_flag = TRUE) / COUNT(*), 2) AS fraud_rate_pct,
    ROUND(100 * SUM(t.status = 'failed') / COUNT(*), 2) AS failure_rate_pct
FROM upi_transaction_history t
JOIN merchant_info m ON m.merchant_id = t.merchant_id
GROUP BY m.merchant_type
ORDER BY fraud_rate_pct DESC;

-- 10. Failure-reason profile
SELECT
    failure_reason,
    COUNT(*) AS failed_transactions,
    SUM(amount) AS failed_transaction_value
FROM upi_transaction_history
WHERE status = 'failed'
GROUP BY failure_reason
ORDER BY failed_transactions DESC;

-- 11. Monthly transaction and fraud trend
SELECT
    DATE_FORMAT(transaction_date, '%Y-%m') AS year_month,
    COUNT(*) AS transactions,
    SUM(amount) AS transaction_value,
    SUM(fraud_flag = TRUE) AS fraud_transactions,
    ROUND(100 * SUM(fraud_flag = TRUE) / COUNT(*), 2) AS fraud_rate_pct
FROM upi_transaction_history
GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
ORDER BY year_month;

-- 12. Customer-level fraud rates for regional analysis
SELECT
    c.customer_id,
    c.region,
    COUNT(t.transaction_id) AS transactions,
    SUM(t.fraud_flag = TRUE) AS fraud_transactions,
    ROUND(100 * SUM(t.fraud_flag = TRUE) / COUNT(t.transaction_id), 4) AS customer_fraud_rate_pct
FROM customer_master c
JOIN upi_transaction_history t ON t.customer_id = c.customer_id
GROUP BY c.customer_id, c.region;

-- 13. High-risk customers by transaction activity
SELECT
    c.customer_id,
    c.full_name,
    c.region,
    c.risk_score,
    COUNT(t.transaction_id) AS transactions,
    SUM(t.fraud_flag = TRUE) AS fraud_transactions,
    ROUND(100 * SUM(t.fraud_flag = TRUE) / COUNT(*), 2) AS fraud_rate_pct
FROM customer_master c
JOIN upi_transaction_history t ON t.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name, c.region, c.risk_score
HAVING COUNT(t.transaction_id) > 0
ORDER BY c.risk_score DESC, fraud_rate_pct DESC;

-- 14. High-value fraud exposure
SELECT
    SUM(CASE WHEN fraud_flag = TRUE THEN amount ELSE 0 END) AS fraud_transaction_value,
    SUM(amount) AS total_transaction_value,
    ROUND(100 * SUM(CASE WHEN fraud_flag = TRUE THEN amount ELSE 0 END) / SUM(amount), 2) AS fraud_value_share_pct
FROM upi_transaction_history;

-- 15. Fraud alerts linked to transactions
SELECT
    COUNT(*) AS fraud_alerts,
    COUNT(DISTINCT transaction_id) AS transactions_with_alerts,
    COUNT(DISTINCT alert_type) AS distinct_alert_types
FROM fraud_alert_history;

-- 16. Reconciliation between transaction fraud flags and fraud-alert coverage
SELECT
    SUM(fraud_flag = TRUE) AS fraud_flagged_transactions,
    COUNT(DISTINCT CASE WHEN f.transaction_id IS NOT NULL THEN t.transaction_id END) AS transactions_with_alerts
FROM upi_transaction_history t
LEFT JOIN fraud_alert_history f ON f.transaction_id = t.transaction_id;

-- 17. Operational performance by channel and status
SELECT
    channel,
    status,
    COUNT(*) AS transactions,
    SUM(amount) AS transaction_value
FROM upi_transaction_history
GROUP BY channel, status
ORDER BY channel, transactions DESC;

-- 18. Time-of-day fraud pattern
SELECT
    HOUR(transaction_date) AS transaction_hour,
    COUNT(*) AS transactions,
    SUM(fraud_flag = TRUE) AS fraud_transactions,
    ROUND(100 * SUM(fraud_flag = TRUE) / COUNT(*), 2) AS fraud_rate_pct
FROM upi_transaction_history
GROUP BY HOUR(transaction_date)
ORDER BY transaction_hour;

-- 19. Data-quality checks: negative amounts and missing transaction keys
SELECT COUNT(*) AS negative_amounts
FROM upi_transaction_history
WHERE amount < 0;

SELECT COUNT(*) AS missing_transaction_ids
FROM upi_transaction_history
WHERE transaction_id IS NULL OR TRIM(transaction_id) = '';

-- 20. Referential-integrity spot check for transaction customers
SELECT COUNT(*) AS orphan_customer_transactions
FROM upi_transaction_history t
LEFT JOIN customer_master c ON c.customer_id = t.customer_id
WHERE c.customer_id IS NULL;
