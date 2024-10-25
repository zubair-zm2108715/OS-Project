#!/bin/bash

# Define log files
DISK_LOG="disk_info.log"
MEM_CPU_LOG="mem_cpu_info.log"

# Get disk usage information for the HOME directory
echo "=== Disk Usage Information for HOME Directory ===" | tee -a $DISK_LOG
du -h --max-depth=1 "$HOME" | tee -a $DISK_LOG

# Show overall disk space information
echo -e "\n=== Overall Disk Space Information ===" | tee -a $DISK_LOG
df -h "$HOME" | tee -a $DISK_LOG

# Get memory and CPU information
echo -e "\n=== Memory and CPU Information ===" | tee -a $MEM_CPU_LOG

# Get used and free memory percentage
free_memory=$(free | grep Mem | awk '{print $4}')
total_memory=$(free | grep Mem | awk '{print $2}')
used_memory_percentage=$(( (total_memory - free_memory) * 100 / total_memory ))

# Get CPU model and number of cores
cpu_model=$(grep -m 1 'model name' /proc/cpuinfo | awk -F: '{print $2}' | xargs)
cpu_cores=$(nproc)

# Display memory usage
echo "Used Memory Percentage: $used_memory_percentage%" | tee -a $MEM_CPU_LOG
echo "CPU Model: $cpu_model" | tee -a $MEM_CPU_LOG
echo "Number of CPU Cores: $cpu_cores" | tee -a $MEM_CPU_LOG

# Display completion message
echo -e "\nInformation logged to $DISK_LOG and $MEM_CPU_LOG."