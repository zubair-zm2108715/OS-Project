#!/bin/bash

LOG_FILE="network.log"

# checks if target IPs are provided
# checks if user provided any arguments. if less than one then it exists
if [ $# -lt 1 ]; then
  echo "Usage: ./traceroute.sh <target_IP>"
  exit 1
fi

TARGET_IP=$1

# Log the current date and time
log_date() {
  echo "$(date +"%Y-%m-%d %H:%M:%S")" | tee -a $LOG_FILE
}

# log diagnostic info
log_date
echo "Traceroute diagnostics for $TARGET_IP" | tee -a $LOG_FILE

# display the routing table
echo "Displaying routing table:" | tee -a $LOG_FILE
netstat -r | tee -a $LOG_FILE

# display hostname
echo "Hostname: $(hostname)" | tee -a $LOG_FILE

# test local DNS server
echo "Testing local DNS server..." | tee -a $LOG_FILE
nslookup google.com | tee -a $LOG_FILE

# traceroute to target IP
echo "Tracing route to $TARGET_IP..." | tee -a $LOG_FILE
traceroute "$TARGET_IP" | tee -a $LOG_FILE

# check if google.com is reachable
echo "Pinging google.com..." | tee -a $LOG_FILE
ping -c 4 google.com | tee -a $LOG_FILE

# reboot the machine if traceroute fails
if ! traceroute "$TARGET_IP" | grep "ms"; then
  echo "Traceroute failed. Rebooting the machine..." | tee -a $LOG_FILE
  reboot
else
  echo "Traceroute successful." | tee -a $LOG_FILE
fi
