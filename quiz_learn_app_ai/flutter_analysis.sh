#!/bin/bash

# Define the output file
OUTPUT_FILE="analysis_report.txt"

# Function to append output to the report file
function append_to_report {
    echo -e "$1" >> $OUTPUT_FILE
    echo -e "$1"
}

# Clear the previous report
echo "Flutter Project Analysis Report" > $OUTPUT_FILE
echo "===============================" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Run Flutter tests with coverage
echo "Running Flutter tests with coverage..."
append_to_report "Running Flutter tests with coverage..."
flutter test --coverage &>> $OUTPUT_FILE
if [ $? -ne 0 ]; then
    append_to_report "Error: Flutter tests failed or coverage directory not found."
else
    append_to_report "Flutter tests completed successfully."
fi
append_to_report ""

# Generate HTML coverage report
echo "Generating HTML coverage report..."
append_to_report "Generating HTML coverage report..."
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html &>> $OUTPUT_FILE
    if [ $? -ne 0 ]; then
        append_to_report "Error: Failed to generate HTML coverage report."
    else
        append_to_report "HTML coverage report generated in coverage/html/index.html."
    fi
else
    append_to_report "Error: genhtml command not found. Please install LCOV."
fi
append_to_report ""

# Run Dart analyzer
echo "Running Dart analyzer..."
append_to_report "Running Dart analyzer..."
flutter analyze &>> $OUTPUT_FILE
if [ $? -ne 0 ]; then
    append_to_report "Error: Dart analyzer found issues."
else
    append_to_report "Dart analyzer completed successfully."
fi
append_to_report ""

# Security checks (manual review recommended)
echo "Security checks (manual review recommended)..."
append_to_report "Security checks (manual review recommended)..."
# Add any manual security checks or reminders here
append_to_report "No automated security checks implemented."
append_to_report ""

# Completion message
echo "All checks completed."
append_to_report "All checks completed."