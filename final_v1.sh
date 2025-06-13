#!/bin/bash

# 運行 monitor
sudo ./memory_monitor.sh &
sudo ./new_cpu_monitor.sh &
sudo ./pages_monitor.sh &

sleep 10
# 運行 eBPF
sudo python3 ksm_try.py &

# 打開 advisor 模式
echo "scan-time" | sudo tee /sys/kernel/mm/ksm/advisor_mode
#echo "none" | sudo tee /sys/kernel/mm/ksm/advisor_mode


# 打開 KSM
echo 1 | sudo tee /sys/kernel/mm/ksm/run &
#echo 0 | sudo tee /sys/kernel/mm/ksm/run 


# 啟動虛擬機
#sudo -E ./create.sh &
sudo -E ./test_create.sh &
wait


