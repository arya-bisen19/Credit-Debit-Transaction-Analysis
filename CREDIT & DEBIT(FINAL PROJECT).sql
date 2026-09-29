create database bank_data;
USE bank_data;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/C&D FOR SQL.csv'
INTO TABLE bank_transaction_clean
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    Customer_ID,
    Customer_Name,
    Account_Number,
    @transaction_date,
    Transaction_Type,
    Amount,
    Balance,
    Description,
    Branch,
    Transaction_Method,
    Currency,
    Bank_Name,
    Year,
    Month,
    Week_Number,
    Day_Name,
    Month_Number,
    Quarter,
    Credit_Amount,
    Debit_Amount,
    Net_Transaction_Amount,
    Transaction_ID,
    Risk_Flag
)
SET Transaction_Date = STR_TO_DATE(@transaction_date, '%m/%d/%Y');

SHOW tables;
describe bank_transaction_clean;

-- KPI 1: TOTAL Amount

select sum(amount) as Total_Amount
from bank_transaction_clean;

-- KPI 2: Total Credit Amount

select sum(amount) as Total_Credit_Amount
from bank_transaction_clean
where Transaction_Type = "Credit";

-- KPI 3: Total Debit Amount
select sum(amount) as Total_Debit_Amount
from bank_transaction_clean
where Transaction_Type = "Debit";

-- KPI 4: Credit to Debit Ratio
SELECT 
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END) /
    SUM(CASE WHEN transaction_type = 'Debit' THEN amount ELSE 0 END) 
    AS Credit_to_Debit_Ratio
FROM bank_transaction_clean;

-- KPI 5: Net Transaction Amount
SELECT 
    SUM(CASE 
        WHEN transaction_type = 'Credit' THEN amount
        WHEN transaction_type = 'Debit' THEN -amount
        ELSE 0
    END) AS Net_Transaction_Amount
FROM bank_transaction_clean;

-- KPI 6: Account Activity Ratio
SELECT 
    COUNT(transaction_id) / COUNT(DISTINCT account_number) 
    AS Account_Activity_Ratio
FROM bank_transaction_clean;

-- Visual 1: Transaction Method Wise Count
SELECT 
    `Transaction_Method`,
    COUNT(*) AS transaction_count,
    CONCAT('Rs. ', FORMAT(SUM(Amount), 2)) AS total_amount
FROM bank_transaction_clean
GROUP BY `Transaction_Method`
ORDER BY transaction_count DESC;

-- Visual 2: Transaction Type-wise Amount
SELECT transaction_type, SUM(amount) AS Total_Amount
FROM bank_transaction_clean
GROUP BY transaction_type;

-- Visual 3: Monthly Transaction Amount
SELECT year, month_number, SUM(amount) AS Total_Amount
FROM bank_transaction_clean
GROUP BY year, month_number
ORDER BY year, month_number;

-- Visual 4: Branch-wise Transaction Amount
SELECT branch, SUM(amount) AS Total_Transaction_Amount
FROM bank_transaction_clean
GROUP BY branch
ORDER BY Total_Transaction_Amount DESC;

-- Visual 5: Bank-wise Transaction Count
SELECT bank_name, COUNT(*) AS Transaction_Count
FROM bank_transaction_clean
GROUP BY bank_name
ORDER BY Transaction_Count DESC;

-- Visual 6: Daily Transaction Trend
SELECT transaction_date, SUM(amount) AS Total_Amount
FROM bank_transaction_clean
GROUP BY transaction_date
ORDER BY transaction_date;

-- Visual 7: Risk Flag-wise Transaction Count
SELECT 
    risk_flag,
    COUNT(*) AS Transaction_Count
FROM bank_transaction_clean
GROUP BY risk_flag
ORDER BY Transaction_Count DESC;