#!/bin/bash

# login.sh - Script to manage SSH login attempts and handle invalid authentications

# Constants
MAX_ATTEMPTS=3
LOG_FILE="invalid_attempts.log"
SERVER_USER="vm1" 
SERVER_IP=""
REMOTE_LOG_PATH="/home/$SERVER_USER/client_timestamp_invalid_attempts.log"

# Prompt for server IP if not set
if [ -z "$SERVER_IP" ]; then
    read -p "Enter the server IP: " SERVER_IP
fi

# Function to log invalid attempts
log_invalid_attempt() {
    local username=$1
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] Invalid login attempt for user: $username" >> "$LOG_FILE"
}

# Function to copy log file to server using sftp
copy_log_to_server() {
    # Create a temporary SFTP batch file
    echo "put $LOG_FILE $REMOTE_LOG_PATH" > sftp_batch
    sftp -b sftp_batch "$SERVER_USER@$SERVER_IP"
    rm sftp_batch
}

# Function to schedule logout
schedule_logout() {
    # Schedule shutdown in 30 seconds
    sudo shutdown -h +1 "Unauthorized access attempt detected. System will logout in 30 seconds."
}

# Main login attempt handling
attempt_count=0

while [ $attempt_count -lt $MAX_ATTEMPTS ]; do
    # Prompt for credentials
    read -p "Username: " username
    echo

    # Attempt SSH login (using sshpass to automate password entry)
    if ssh -o StrictHostKeyChecking=no "$username@$SERVER_IP" 'exit'; then
        echo "Login successful!"
        exit 0
    else
        attempt_count=$((attempt_count + 1))
        remaining=$((MAX_ATTEMPTS - attempt_count))
        
        # Log the invalid attempt
        log_invalid_attempt "$username"
        
        if [ $remaining -gt 0 ]; then
            echo "Invalid credentials. $remaining attempts remaining."
        else
            echo "Unauthorized user!"
            # Copy log file to server
            copy_log_to_server
            # Schedule logout
            schedule_logout
            exit 1
        fi
    fi
done
