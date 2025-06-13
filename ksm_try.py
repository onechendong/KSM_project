# eBPF monitor
from bcc import BPF
import time

# 取得開機時間（秒）
with open("/proc/uptime", "r") as f:
    uptime_seconds = float(f.readline().split()[0])  # 開機後經過的時間（秒）
boot_time_offset = time.time() - uptime_seconds  # 真實開機時間（UNIX TIME）

# 設定運行時間（秒）
duration = 14400
start_time = time.time()  # 記錄開始時間

# BPF 程式碼
prog = """
#include <uapi/linux/ptrace.h>

int hello_world(struct pt_regs *ctx) {
    u64 ts = bpf_ktime_get_ns();  // 取得當前內核 monotonic 時間（ns）
    bpf_trace_printk("%llu\\n", ts);  // 輸出時間戳
    return 0;
}
"""

# 編譯並載入 BPF 程式
b = BPF(text=prog)

# 綁定到 replace_page 函數
b.attach_kprobe(event="replace_page", fn_name="hello_world")

# 打開文件寫入輸出
with open("ebpf.txt", "w") as f:
    while time.time() - start_time < duration:
        try:
            (_, _, _, _, _, msg) = b.trace_fields()
            timestamp_ns = int(msg)  # 取得 BPF 傳來的時間戳（ns）

            # 計算 boot time 格式的時間
            boot_time_sec = (timestamp_ns / 1e9)  # 轉換為秒數
            formatted_time = f"[{boot_time_sec:.6f}]"  # 格式化為 6 位小數

            log_entry = f"{formatted_time}\n"
            f.write(log_entry)  # 寫入文件
            f.flush()  # 確保立即寫入（避免緩衝區延遲）

        except ValueError:
            continue
        except KeyboardInterrupt:
            break  # 允許手動中斷


print("📍 Monitoring finished. Results saved to ebpf.txt")

