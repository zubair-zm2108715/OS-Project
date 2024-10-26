#!/bin/bash

# search.sh - Script to find files larger than 1MB and notify admin

# Configuration
ADMIN_EMAIL="QUID@qu.edu.qa"  # Administrator's email address
BIGFILE="bigfile"            # Output file name
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Function to send email
send_email() {
    local file_count=$1
    local email_body="
Date: $TIMESTAMP
Number of files found: $file_count

File Details:
$(cat "$BIGFILE")

This is an automated message from the file search script.
"
    
    # Using mail command to send email
    echo "$email_body" | mail -s "Large File Report - $TIMESTAMP" "$ADMIN_EMAIL"
}

# Function to check if mail is installed
check_mail_installed() {
    if ! command -v mail &> /dev/null; then
        echo "Mail command not found. Installing mailutils..."
        sudo apt-get update
        sudo apt-get install -y mailutils
    fi
}

# Create or clear the bigfile
echo "File Search Report - $TIMESTAMP" > "$BIGFILE"
echo "----------------------------------------" >> "$BIGFILE"

echo "Searching for files larger than 1MB..."

# Find files larger than 1M and store details
while IFS= read -r file; do
    if [ -n "$file" ]; then
        # Get file size in human-readable format
        size=$(du -h "$file" | cut -f1)
        
        # Get last modification time
        mod_time=$(stat -c "%y" "$file")
        
        # Add file information to bigfile
        echo "File: $file" >> "$BIGFILE"
        echo "Size: $size" >> "$BIGFILE"
        echo "Last modified: $mod_time" >> "$BIGFILE"
        echo "----------------------------------------" >> "$BIGFILE"
    fi
done < <(find "$HOME" -type f -size +1M 2>/dev/null)

# Count the number of files found
file_count=$(grep -c "File: " "$BIGFILE")

# Add summary to bigfile
echo -e "\nSummary:" >> "$BIGFILE"
echo "Search Date: $TIMESTAMP" >> "$BIGFILE"
echo "Total files found: $file_count" >> "$BIGFILE"

# Check if any files were found
if [ $file_count -gt 0 ]; then
    echo "Found $file_count files larger than 1MB."
    echo "Results have been saved to $BIGFILE"
    
    # Ensure mail is installed
    check_mail_installed
    
    # Send email to administrator
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

# Display search complete message
echo "Search operation completed at $(date '+%Y-%m-%d %H:%M:%S')"
