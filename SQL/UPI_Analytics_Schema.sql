-- UPI Transaction Analytics

CREATE DATABASE IF NOT EXISTS upi_analytics;
USE upi_analytics;

DROP TABLE IF EXISTS fraud_alert_history;
DROP TABLE IF EXISTS customer_feedback_surveys;
DROP TABLE IF EXISTS upi_transaction_history;
DROP TABLE IF EXISTS merchant_info;
DROP TABLE IF EXISTS upi_account_details;
DROP TABLE IF EXISTS device_info;
DROP TABLE IF EXISTS customer_master;

CREATE TABLE customer_master (
    customer_id         VARCHAR(30)  NOT NULL,
    full_name           VARCHAR(150),
    age                 INT,
    gender              VARCHAR(20),
    mobile_number       VARCHAR(30),
    region              VARCHAR(50),
    date_joined         DATE,
    is_business_user    BOOLEAN,
    risk_score          DECIMAL(10,4),
    gender_typo_chk     VARCHAR(50),
    PRIMARY KEY (customer_id)
);

CREATE TABLE device_info (
    device_id            VARCHAR(30)  NOT NULL,
    customer_id          VARCHAR(30),
    app_version          VARCHAR(30),
    device_type          VARCHAR(50),
    device_type_typo_chk VARCHAR(50),
    is_rooted             VARCHAR(10),
    last_active           DATETIME,
    customer_chk          VARCHAR(50),
    PRIMARY KEY (device_id),
    CONSTRAINT fk_device_customer
        FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id)
);

CREATE TABLE upi_account_details (
    upi_id               VARCHAR(100) NOT NULL,
    customer_id          VARCHAR(30),
    bank_name             VARCHAR(100),
    account_type          VARCHAR(50),
    status                VARCHAR(30),
    date_added            DATETIME,
    bank_name_typo_chk    VARCHAR(100),
    account_type_typo_chk VARCHAR(50),
    upi_type_typo_chk     VARCHAR(50),
    status_typo_chk       VARCHAR(50),
    customer_chk          VARCHAR(50),
    PRIMARY KEY (upi_id),
    CONSTRAINT fk_upi_customer
        FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id)
);

CREATE TABLE merchant_info (
    merchant_id           VARCHAR(30)  NOT NULL,
    merchant_name         VARCHAR(150),
    merchant_type         VARCHAR(80),
    region                VARCHAR(50),
    onboard_date          DATE,
    risk_score            DECIMAL(10,4),
    merchant_type_typo_chk VARCHAR(80),
    merch_type_typo_chk    VARCHAR(80),
    region_typo_chk        VARCHAR(50),
    PRIMARY KEY (merchant_id)
);

CREATE TABLE upi_transaction_history (
    transaction_id        VARCHAR(40)  NOT NULL,
    transaction_date      DATETIME,
    customer_id           VARCHAR(30),
    upi_id                VARCHAR(100),
    device_id             VARCHAR(30),
    merchant_id           VARCHAR(30),
    amount                DECIMAL(14,2),
    channel               VARCHAR(50),
    device_type           VARCHAR(50),
    counterpart_upi       VARCHAR(100),
    status                VARCHAR(30),
    failure_reason        VARCHAR(150),
    fraud_flag            BOOLEAN,
    reversal_flag         BOOLEAN,
    customer_chk          VARCHAR(50),
    device_chk            VARCHAR(50),
    channel_typo_chk      VARCHAR(50),
    device_type_typo_chk  VARCHAR(50),
    failure_reason_typo_chk VARCHAR(150),
    merchant_chk          VARCHAR(50),
    upi_id_typo_chk       VARCHAR(100),
    transaction_date_only DATE,
    transaction_time      TIME,
    hour                  INT,
    day_name              VARCHAR(15),
    day_of_week            INT,
    month_num              INT,
    month_name             VARCHAR(15),
    year_num               INT,
    PRIMARY KEY (transaction_id),
    CONSTRAINT chk_transaction_amount_nonnegative CHECK (amount >= 0),
    CONSTRAINT fk_tx_customer
        FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id),
    CONSTRAINT fk_tx_upi
        FOREIGN KEY (upi_id) REFERENCES upi_account_details(upi_id),
    CONSTRAINT fk_tx_device
        FOREIGN KEY (device_id) REFERENCES device_info(device_id),
    CONSTRAINT fk_tx_merchant
        FOREIGN KEY (merchant_id) REFERENCES merchant_info(merchant_id)
);

CREATE TABLE customer_feedback_surveys (
    feedback_id          VARCHAR(40) NOT NULL,
    customer_id          VARCHAR(30),
    date_submitted       DATE,
    feedback_text        TEXT,
    issue_type           VARCHAR(100),
    resolved             BOOLEAN,
    satisfaction_score   DECIMAL(10,4),
    issue_type_typo_chk  VARCHAR(100),
    validation_status    VARCHAR(50),
    customer_chk         VARCHAR(50),
    PRIMARY KEY (feedback_id),
    CONSTRAINT fk_feedback_customer
        FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id)
);

CREATE TABLE fraud_alert_history (
    alert_id              VARCHAR(40) NOT NULL,
    transaction_id        VARCHAR(40),
    alert_date             DATE,
    alert_time             TIME,
    alert_type             VARCHAR(100),
    remarks                TEXT,
    resolution_date        DATE,
    alert_type_typo_chk    VARCHAR(100),
    resolution_date_only   DATE,
    PRIMARY KEY (alert_id),
    CONSTRAINT fk_alert_transaction
        FOREIGN KEY (transaction_id) REFERENCES upi_transaction_history(transaction_id)
);

CREATE INDEX idx_tx_customer     ON upi_transaction_history(customer_id);
CREATE INDEX idx_tx_device       ON upi_transaction_history(device_id);
CREATE INDEX idx_tx_merchant     ON upi_transaction_history(merchant_id);
CREATE INDEX idx_tx_upi          ON upi_transaction_history(upi_id);
CREATE INDEX idx_tx_date         ON upi_transaction_history(transaction_date);
CREATE INDEX idx_tx_fraud        ON upi_transaction_history(fraud_flag);
CREATE INDEX idx_feedback_customer ON customer_feedback_surveys(customer_id);
CREATE INDEX idx_alert_transaction ON fraud_alert_history(transaction_id);
