# Data Test

## Description
Data Test Lambda make main functionality of DQG module: Profiling, Test Generating, Test Run

### Libraries and Tools
great-expectations
ydata-profiling
awswrangler

### Profiling
Based on ydata-profiling. Read file into Pandas Data from various source and collect statistical information about data
Input: Source Path
Output: Profiling report(json and html)

### Test Generating
Expectations applied through rule based algorithm which depends on profiling info about the data.
Input: Profiling report(json)
Output: Test suite(GX json)

### Test Run
Generated suite run by GX engine and built GX test reports
Input: Test suite(GX json) and data(pandas dataframe)
Output: validation results(GX json and GX html)

## Flow
![Preview Image](https://raw.githubusercontent.com/provectus/data-quality-gate/main/functions/data_test/data_test_flow.png)

## Process

1. Read params from config based on pipeline name + suite_name
2. Read data from source into pandas dataframe: s3, athena, hudi, redshift. And format: parquet, csv, json
3. Profile data and save reports to s3 with json and html
4. if necessary generate test suite based on profiling report and save to s3 with json
5. Run generated test suite and save validation results to s3 with json and html

