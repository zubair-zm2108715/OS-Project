#!/bin/bash

ADMIN_EMAIL="sa2108209@qu.edu.qa"
BIGFILE="bigfile"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

send_email() {
    local file_count=$1
    local email_body="
Date: $TIMESTAMP
Number of files found: $file_count

File Details:
$(cat "$BIGFILE")

This is an automated message from the file search script.
"
    echo "$email_body" | mail -s "Large File Report - $TIMESTAMP" "$ADMIN_EMAIL"
}

check_mail_installed() {
    if ! command -v mail &> /dev/null; then
        echo "Mail command not found. Installing mailutils..."
        sudo apt-get update && sudo apt-get install -y mailutils
    fi
}

echo "File Search Report - $TIMESTAMP" > "$BIGFILE"
echo "----------------------------------------" >> "$BIGFILE"

while IFS= read -r file; do
    if [ -n "$file" ]; then
        size=$(du -h "$file" | cut -f1)
        mod_time=$(stat -c "%y" "$file")
        echo "File: $file" >> "$BIGFILE"
        echo "Size: $size" >> "$BIGFILE"
        echo "Last modified: $mod_time" >> "$BIGFILE"
        echo "----------------------------------------" >> "$BIGFILE"
    fi
done < <(find "$HOME" -type f -size +1M 2>/dev/null)

file_count=$(grep -c "File: " "$BIGFILE")

echo -e "\nSummary:" >> "$BIGFILE"
echo "Search Date: $TIMESTAMP" >> "$BIGFILE"
echo "Total files found: $file_count" >> "$BIGFILE"

if [ $file_count -gt 0 ]; then
    echo "Found $file_count files larger than 1MB."
    echo "Results have been saved to $BIGFILE"
    check_mail_installed
    echo "Sending email notification to administrator..."
    send_email "$file_count"
    if [ $? -eq 0 ]; then
        echo "Email notification sent successfully."
    else
        echo "Error sending email notification."
    fi
else
    echo "No files larger than 1MB were found."
    echo "No email notification will be sent."
fi

echo "Search operation completed at $(date '+%Y-%m-%d %H:%M:%S')"
