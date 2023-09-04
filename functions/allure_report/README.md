# Allure Report

## Description
Allure Report Lambda convert GX validations format to Best open-source Test report tool format and generate report

### Libraries and Tools
- great-expectations
- Allure 
- awswrangler

### Convert results
Convert GX validations json results to Allure json result through custom mapper\
Input: Path to json validation result on S3\
Output: allure results in json format\

### Generate Report
Generate from Allure json results html page\
Input: Allure results(json)\
Output: Allure report(html+JS)

## Flow
![Tux, the Linux mascot](/functions/allure_report/allure_report_flow.png)

## Process

1. Copy to Lambda runtime volume GX validation file from S3
2. Run it through custom mapper and get Allure results in json format
3. Generate by Allure report from results
4. Save Report to S3
