#!/bin/bash

# Constants
MAX_ATTEMPTS=3
LOG_FILE="client_timestamp_invalid_attempts.log"
SERVER_USER="vm1" # Replace with your server username
SERVER_IP=""   
REMOTE_LOG_PATH="/home/$SERVER_USER/$LOG_FILE"

# Prompt for server IP if not set
if [ -z "$SERVER_IP" ]; then
    read -p "Enter the server IP: " SERVER_IP
fi

# Function to log invalid attempts
log_invalid_attempt() {
    local username=$1
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] Invalid login attempt for user: $username" >> "$LOG_FILE"
    # Copy log file to server using sftp
    echo "put $LOG_FILE $REMOTE_LOG_PATH" | sftp "$SERVER_USER@$SERVER_IP"
}

# Function to schedule logout
schedule_logout() {
    # Schedule shutdown in 30 seconds
    sudo shutdown -h +0.5 "Unauthorized access attempt detected. System will logout in 30 seconds."
}

# Main login attempt handling
attempt_count=0
while [ $attempt_count -lt $MAX_ATTEMPTS ]; do
    # Prompt for credentials
    read -p "Username: " username
    read -s -p "Password: " password
    echo

    # Attempt SSH login (using sshpass to automate password entry)
    if sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@$SERVER_IP" 'exit'; then
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
            # Schedule logout
            schedule_logout
            exit 1
        fi
    fi
done
