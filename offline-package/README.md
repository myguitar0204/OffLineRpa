# RPA 離線套件說明

## 套件內容

```
rpa-offline-package/          ← 整個資料夾複製到目標電腦
├── install.ps1               ← 安裝腳本（以系統管理員執行）
├── uv.exe                    ← Python 套件管理工具
├── python-packages/          ← 所有 Python 套件（離線安裝用）
│   ├── playwright-1.60.0-py3-none-win_amd64.whl
│   ├── httpx-0.28.1-py3-none-any.whl
│   └── ...（共 10 個 wheel 檔）
├── chromium/                 ← Chromium 瀏覽器（412MB，Playwright 使用）
│   └── chromium-1223/
└── rpa-project/              ← RPA 腳本範本
    └── main.py
```

---

## 目標電腦需求

- Windows 10/11（64位元）
- 不需要網路連線
- 需要 Ollama 已安裝並載入 Gemma4:12B 模型（`http://localhost:11434`）

---

## 安裝步驟（目標電腦）

### Step 1 — 複製套件
將整個 `rpa-offline-package` 資料夾複製到目標電腦（建議放 `C:\rpa-offline-package`）

### Step 2 — 執行安裝腳本
以**系統管理員**開啟 PowerShell，執行：
```powershell
cd C:\rpa-offline-package
.\install.ps1
```

安裝完成後重新開啟 PowerShell。

### Step 3 — 執行 RPA 腳本
```powershell
cd C:\rpa-project
uv run python main.py
```

---

## 修改 RPA 腳本

編輯 `C:\rpa-project\main.py`：

```python
# 1. 修改內網網址
page.goto("http://your-intranet-url")

# 2. 修改 iframe 選擇器（用瀏覽器 F12 DevTools 查 id/name）
frame = page.frame_locator("iframe#main-frame")

# 3. 填入實際操作步驟
frame.locator("input[name='username']").fill("帳號")
frame.locator("input[name='password']").fill("密碼")
frame.locator("button[type='submit']").click()
```

---

## 讓 Gemma4 幫你生成腳本

在已有 Ollama 的機器上執行：
```python
import httpx

def ask_gemma(prompt: str) -> str:
    resp = httpx.post(
        "http://localhost:11434/api/generate",
        json={"model": "gemma4:12b", "prompt": prompt, "stream": False},
        timeout=120,
    )
    return resp.json()["response"]

task = """
請幫我寫一個 Playwright Python 腳本，完成以下步驟：
1. 開啟 http://intranet/system
2. 進入 id 為 'content' 的 iframe
3. 點選「新增」按鈕
4. 填入表單欄位 name='title' 值為「測試」
5. 點選「送出」
"""
print(ask_gemma(task))
```

---

## iframe 常見問題

| 問題 | 解法 |
|------|------|
| iframe 還沒載入就操作 | `page.wait_for_selector("iframe#xxx")` |
| 巢狀 iframe | `frame_locator().frame_locator()` |
| 找不到元素 | 按 F12 → Elements 找 id/name/class |

---

## 套件版本資訊

| 套件 | 版本 |
|------|------|
| uv | 0.11.8 |
| playwright | 1.60.0 |
| httpx | 0.28.1 |
| Chromium | 1223 |
| Python（建議）| 3.13 |
