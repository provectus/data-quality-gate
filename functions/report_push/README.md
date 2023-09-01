# Report Push

## Description
Report Push Lambda Collect metadata, push metrics and create bugs

### Libraries and Tools
- jira
- awswrangler

### Metadata
Collect all necessary metadata about test run from GX and Allure report and save info to DynamoDB table\
Input: Allure and GX report\
Output: DynamoDB table record

### Metrics
Based on metadata send metrics about run to sns topic and cloudwatch metric\
Input: Allure and GX report\
Output: pushed cloudwatch metric and record at sns topic 

### Bugs
If necessary create bugs automatically at Jira, previously check that this bug did not exist yet, opposite - reopen existed bug\
Input: Allure and GX report\
Output: Bug at Jira

## Flow
![Tux, the Linux mascot](/functions/report_push/report_push_flow.png)

## Process

1. Read data from GX and Allure report
2. Send necessary info to DynamoDB
3. If necessary and failed>0 send metrics to Cloudwatch and sns topic
4. If necessary create bug at Jira
