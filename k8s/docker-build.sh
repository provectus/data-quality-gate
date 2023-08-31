#!/bin/bash

echo "Building images..."
docker build --platform linux/amd64 -t dqg_data_test_local:0.0.1 ../functions/data_test
docker build --platform linux/amd64 -t dqg_alure_report_local:0.0.1 ../functions/allure_report 
docker build --platform linux/amd64 -t dqg_report_push_local:0.0.1 ../functions/report_push

docker images | grep "dqg_"