#!/bin/bash
#
# A shell script for tracking your blood pressure in a CSV file.
#
# https://github.com/aheckler/bp-log

# Path to the CSV log file
LOG_FILE=~/Documents/Medical/BloodPressureLog.csv

# Current date in YYYY-MM-DD format
CURRENT_DATE=$(date --iso-8601)

echo "The date is: ${CURRENT_DATE}"

# Prompt for current blood pressure
read -p "Systolic blood pressure: " SYSTOLIC_BP
read -p "Diastolic blood pressure: " DIASTOLIC_BP

# Append current reading to log
echo "${CURRENT_DATE},${SYSTOLIC_BP},${DIASTOLIC_BP}" >> ${LOG_FILE}

echo "Blood pressure recorded. Thanks! :)"

# Get a past date to calculate rolling average
PAST=$(date --iso-8601 --date="90 days ago")
PAST_TR=$(echo ${PAST} | tr -d "-")

# Remove first line and all dashes from log data
SANITIZED_DATA=$(cat ${LOG_FILE} | tail --lines=+2 | tr -d "-")

# Extract all log records since $PAST date
ROLLING_AVE_DATA=$(echo "${SANITIZED_DATA}" | awk -v PAST_TR="${PAST_TR}" '$1 > PAST_TR')

# Average readings and round to nearest integer
SYSTOLIC_BP_ROLLING_AVERAGE=$(echo "${ROLLING_AVE_DATA}" | awk -F "," '{ SUM += $2 } END { print SUM / NR }' | numfmt --to=si --round=nearest)
DIASTOLIC_BP_ROLLING_AVERAGE=$(echo "${ROLLING_AVE_DATA}" | awk -F "," '{ SUM += $3 } END { print SUM / NR }' | numfmt --to=si --round=nearest)

# Echo averages
echo "Average BP since ${PAST} is ${SYSTOLIC_BP_ROLLING_AVERAGE} / ${DIASTOLIC_BP_ROLLING_AVERAGE}."

exit 0;
