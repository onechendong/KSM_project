#!/bin/bash

# 設定輸出檔案
OUTPUT_FILE="pages.txt"

# 先寫入表頭
echo "Timestamp        pages_shared    pages_sharing   pages_to_scan" > "$OUTPUT_FILE"

# 執行 3600 次，每秒一次
for ((i=0; i<14400; i++)); do
    # 取得當前時間戳記
    TIMESTAMP=$(python3 -c 'import time; print(f"[{time.clock_gettime(time.CLOCK_MONOTONIC):.6f}]")')
    # 取得 pages_shared 和 pages_sharing 數量
    PAGES_SHARED=$(cat /sys/kernel/mm/ksm/pages_shared)
    PAGES_SHARING=$(cat /sys/kernel/mm/ksm/pages_sharing)
    PAGES_TO_SCAN=$(cat /sys/kernel/mm/ksm/pages_to_scan)

    # 寫入檔案
    echo "$TIMESTAMP    $PAGES_SHARED    $PAGES_SHARING   $PAGES_TO_SCAN" >> "$OUTPUT_FILE"

    # 等待 1 秒
    sleep 1
done
echo "page monitor completed 📙 "


