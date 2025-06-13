#!/bin/bash

# 設定輸出檔案
OUTPUT_FILE="memory.txt"

# 清空舊的記錄（如果有）

> "$OUTPUT_FILE"



# 記錄開始時間
echo "boot time      total used free shared buff/cache available" >> "$OUTPUT_FILE"


# 連續監測 1 hr
for i in {1..14400}; do
    # 取得時間戳
    BOOT_TIMESTAMP=$(python3 -c 'import time; print(f"[{time.clock_gettime(time.CLOCK_MONOTONIC):.6f}]")')
    # 解析 free -h 的輸出
    MEM_STATS=$(free -h | awk 'NR==2 {print $2, $3, $4, $5, $6, $7}')
    
    # 寫入檔案
    echo "$BOOT_TIMESTAMP, $MEM_STATS" >> "$OUTPUT_FILE"
    
    # 等待 1 秒
    sleep 1
done

echo "Ⓜ️ 記錄完成，數據已保存至 $OUTPUT_FILE"


