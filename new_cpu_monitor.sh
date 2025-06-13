#!/bin/bash

# 設定輸出檔案
OUTPUT_FILE="new_cpu.txt"

# 先寫入表頭
echo "Timestamp         %usr %system  %guest   %wait    %CPU   CPU" > "$OUTPUT_FILE"

# 執行 3600 次，每秒一次
for ((i=0; i<14400; i++)); do
    # 取得當前時間戳記
    TIMESTAMP=$(python3 -c 'import time; print(f"[{time.clock_gettime(time.CLOCK_MONOTONIC):.6f}]")')
    # 取得 KSM 的 CPU 使用率
    KSM_CPU=$(pidstat -C ksmd 1 1 | awk 'NR==4 {print $4, $5, $6, $7, $8, $9}')
    
    # 如果 KSM 沒有運行，設定為 0
    if [ -z "$KSM_CPU" ]; then
        KSM_CPU="0.00"
    fi
    
    # 寫入檔案
    echo "$TIMESTAMP    $KSM_CPU" >> "$OUTPUT_FILE"

    # 等待 1 秒
    #sleep 1
done
echo "💿 記錄完成，數據已保存至 $OUTPUT_FILE"


