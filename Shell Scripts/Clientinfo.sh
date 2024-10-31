#!/bin/bash

# clientinfo.sh - Script to gather and transfer system information hourly

# Configuration
SERVER_USER="vm1"  # Replace with your server username
SERVER_IP=""    # Replace with your server IP
LOCAL_LOG="process_info.log"
REMOTE_PATH="/home/$SERVER_USER/client_logs"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
REMOTE_FILE="process_info_${TIMESTAMP}.log"

# Prompt for server IP if not set
if [ -z "$SERVER_IP" ]; then
    read -p "Enter the server IP: " SERVER_IP
fi

# Function to gather process tree
get_process_tree() {
    echo "=== Process Tree ===" >> "$LOCAL_LOG"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOCAL_LOG"
    pstree -p >> "$LOCAL_LOG"
    echo -e "\n" >> "$LOCAL_LOG"
}

# Function to find zombie processes
get_zombie_processes() {
    echo "=== Dead/Zombie Processes ===" >> "$LOCAL_LOG"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOCAL_LOG"
    ps aux | awk '$8=="Z"' >> "$LOCAL_LOG"
    echo -e "\n" >> "$LOCAL_LOG"
}

# Function to get CPU usage
get_cpu_usage() {
    echo "=== CPU Usage by Process ===" >> "$LOCAL_LOG"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOCAL_LOG"
    ps aux --sort=-%cpu | head -n 11 >> "$LOCAL_LOG"
    echo -e "\n" >> "$LOCAL_LOG"
}

# Function to get memory usage
get_memory_usage() {
    echo "=== Memory Usage by Process ===" >> "$LOCAL_LOG"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOCAL_LOG"
    ps aux --sort=-%mem | head -n 11 >> "$LOCAL_LOG"
    echo -e "\n" >> "$LOCAL_LOG"
}

# Function to get top resource consumers
get_top_resources() {
    echo "=== Top 5 Resource-Consuming Processes ===" >> "$LOCAL_LOG"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOCAL_LOG"
    echo "By CPU Usage:" >> "$LOCAL_LOG"
    ps aux --sort=-%cpu | head -n 6 | tail -n 5 >> "$LOCAL_LOG"
    echo -e "\nBy Memory Usage:" >> "$LOCAL_LOG"
    ps aux --sort=-%mem | head -n 6 | tail -n 5 >> "$LOCAL_LOG"
    echo -e "\n" >> "$LOCAL_LOG"
}

# Function to transfer file to server
transfer_to_server() {
    # Create remote directory if it doesn't exist
    ssh "$SERVER_USER@$SERVER_IP" "mkdir -p $REMOTE_PATH"
    
    # Copy file to server
    scp "$LOCAL_LOG" "$SERVER_USER@$SERVER_IP:$REMOTE_PATH/$REMOTE_FILE"
    
    if [ $? -eq 0 ]; then
        echo "File transferred successfully to server"
        # Clean up local log file
        > "$LOCAL_LOG"
    else
        echo "Error transferring file to server"
    fi
}

# Main execution function
gather_and_transfer() {
    # Clear existing log
    > "$LOCAL_LOG"
    
    # Gather all information
    get_process_tree
    get_zombie_processes
    get_cpu_usage
    get_memory_usage
    get_top_resources
    
    # Transfer to server
    transfer_to_server
}

# Setup cron job if it doesn't exist
setup_cron() {
    # Check if cron job already exists
    if ! crontab -l 2>/dev/null | grep -q "$0"; then
        # Add to crontab (runs every hour)
        (crontab -l 2>/dev/null; echo "0 * * * * $(readlink -f $0)") | crontab -
        echo "Cron job has been set up to run every hour"
    fi
}

# If script is run directly (not by cron)
if [ "$1" != "CRON" ]; then
    # Set up cron job
    setup_cron
    
    echo "Initial run of information gathering..."
    gather_and_transfer
    echo "Script has been set up to run every hour"
    echo "You can check the cron logs for execution details"
else
    # When run by cron
    gather_and_transfer
fi
