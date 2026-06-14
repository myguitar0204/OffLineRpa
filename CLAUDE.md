# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 專案目的

封閉內網環境的 RPA 自動化專案。使用本機 Ollama（Gemma4 12B）生成 Playwright 腳本，操作內網 iframe 網頁執行固定流程。

## 執行環境

- **目標機器**：Windows，無對外網路
- **LLM**：Ollama + Gemma4:12B，API 位於 `http://localhost:11434`
- **瀏覽器自動化**：Playwright + Chromium（離線，`%LOCALAPPDATA%\ms-playwright\chromium-1223`）
- **Python 管理**：uv（`C:\rpa-tools\uv.exe`）
- **專案位置**：`C:\rpa-project`（安裝後）

## 執行指令

```powershell
# 執行 RPA 腳本
cd C:\rpa-project
uv run python scripts/main.py

# 新增腳本後安裝套件
uv pip install --no-index --find-links C:\rpa-offline-package\python-packages <套件名>
```

## 離線套件包

所有依賴打包在獨立 repo：https://github.com/myguitar0204/rpa-offline-package

套件包含（Python 3.13 / Windows x64）：
- `playwright 1.60.0`
- `httpx 0.28.1`
- Chromium 1223（412MB，需 USB 搬移，不在 GitHub）
- `uv 0.11.8`（需 USB 搬移，不在 GitHub）

## 架構

```
scripts/
└── main.py     ← RPA 腳本範本，每個任務一支腳本
```

`main.py` 結構：
- `ask_gemma(prompt)` — 呼叫 Ollama API 取得 AI 回應
- `run_rpa()` — Playwright 主流程，操作 iframe 網頁

## iframe 操作重點

```python
# 等待 iframe 載入後再操作
page.wait_for_selector("iframe#main-frame")
frame = page.frame_locator("iframe#main-frame")

# 巢狀 iframe
frame2 = frame.frame_locator("iframe#inner")

# 在 iframe 內操作
frame.locator("input[name='xxx']").fill("值")
frame.locator("button[type='submit']").click()
```

元素 selector 請用瀏覽器 F12 → Elements 面板查找。

## 新增腳本流程

1. 在 `scripts/` 建立新的 `.py` 檔
2. 描述需求給 Gemma4，取得 Playwright 腳本
3. 貼入並修改 `page.goto()` 網址與 iframe selector
4. `uv run python scripts/<檔名>.py` 手動驗證
5. 確認無誤後加入 Windows 工作排程器
