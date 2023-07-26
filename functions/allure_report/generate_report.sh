FOLDER=$1
BUCKET=$2
rm -rf  /tmp/.[!.]* /tmp/*
echo "$BUCKET"
aws s3 sync s3://"$BUCKET"/allure/"$FOLDER"/result /tmp/result
allure/allure-2.14.0/bin/allure generate /tmp/result --clean -o /tmp/allure-report
aws s3 sync /tmp/allure-report s3://"$BUCKET"/allure/"$FOLDER"/allure-report
