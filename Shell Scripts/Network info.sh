#!/bin/bash

# checks if target IPs are provided
# checks if user provided any arguments. if less than one then it exists
if [ $# -lt 1 ]; then
  echo "Usage: ./network.sh <target_IPs>"
  exit 1
fi

# Define target IPs
TARGET_IPS=("$@")
LOG_FILE="network.log"

# Log the current date and time into the log file
log_date() {
  echo "$(date +"%Y-%m-%d %H:%M:%S")" | tee -a $LOG_FILE
}

# pings the target IP and log the results
ping_test() {
  local target_ip=$1 # stores arguments in a local variable
  for i in {1..3}; do

    log_date # logs date
    echo "Pinging $target_ip (Attempt $i)..." | tee -a $LOG_FILE # logs attempts

    # pings 4 times with a time out response of 5 seconds
    # if the ping works, it prints out that it did, logs it and exits the function
    if ping -c 4 -W 5 "$target_ip" > /dev/null; then
      echo "Connectivity with $target_ip is ok" | tee -a $LOG_FILE
      return 0

    # if pinging fails, it logs it, and continue by handing the ip address to trace router
    else
      echo "Ping to $target_ip failed" | tee -a $LOG_FILE
    fi
  done

  # If ping fails after 3 attempts, run traceroute.sh
  echo "Connectivity with $target_ip failed after 3 attempts. Running traceroute.sh..." | tee -a $LOG_FILE
  ./traceroute.sh "$target_ip"
}

# Ping each IP given in the command
for ip in "${TARGET_IPS[@]}"; do
  ping_test "$ip"
done
