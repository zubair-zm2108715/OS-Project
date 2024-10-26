#!/bin/bash

# check.sh - Script to find files with 777 permissions and change them to 700

# Constants
LOG_FILE="perm_change.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Create or clear the log file
echo "Permission Change Log - Started at $TIMESTAMP" > "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"

# Function to log changes
log_change() {
    local file=$1
    local old_perm=$2
    echo "[$TIMESTAMP] Changed permissions for: $file" >> "$LOG_FILE"
    echo "    Old permissions: $old_perm" >> "$LOG_FILE"
    echo "    New permissions: 700" >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
}

# Function to display file information
display_file_info() {
    local file=$1
    local perm=$2
    echo "Found file with 777 permissions:"
    echo "    File: $file"
    echo "    Current permissions: $perm"
    echo "----------------------------------------"
}

echo "Searching for files with permission 777..."
echo "----------------------------------------"

# Find files with 777 permissions in the current user's home directory
while IFS= read -r file; do
    if [ -n "$file" ]; then
        # Get the original permissions in human-readable format
        old_perm=$(stat -c "%A" "$file")
        
        # Display information on screen
        display_file_info "$file" "$old_perm"
        
        # Change permissions to 700
        chmod 700 "$file"
        
        # Log the change
        log_change "$file" "$old_perm"
    fi
done < <(find "$HOME" -type f -perm 777 2>/dev/null)

# Summary
total_files=$(grep -c "Changed permissions" "$LOG_FILE")

echo "----------------------------------------"
echo "Operation completed at $(date '+%Y-%m-%d %H:%M:%S')"
echo "Total files processed: $total_files"
echo "Details have been saved to: $LOG_FILE"

# Add summary to log file
echo "----------------------------------------" >> "$LOG_FILE"
echo "Summary: Total files processed: $total_files" >> "$LOG_FILE"
echo "Operation completed at $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
