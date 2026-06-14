# RPA 離線安裝腳本
# 在目標電腦（無網路）執行此腳本
# 需以系統管理員身份執行

$ErrorActionPreference = "Stop"
$PackageDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== RPA 離線安裝開始 ===" -ForegroundColor Cyan

# 1. 安裝 uv
Write-Host "[1/4] 安裝 uv..." -ForegroundColor Yellow
$uvExe = Join-Path $PackageDir "uv.exe"
$uvTarget = "C:\rpa-tools\uv.exe"
New-Item -ItemType Directory -Force -Path "C:\rpa-tools" | Out-Null
Copy-Item $uvExe $uvTarget -Force

# 加入 PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
if ($currentPath -notlike "*C:\rpa-tools*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;C:\rpa-tools", "Machine")
    $env:PATH = "$env:PATH;C:\rpa-tools"
}
Write-Host "  uv 安裝完成：$uvTarget" -ForegroundColor Green

# 2. 建立專案並安裝套件
Write-Host "[2/4] 建立 RPA 專案..." -ForegroundColor Yellow
$projectDir = "C:\rpa-project"
New-Item -ItemType Directory -Force -Path $projectDir | Out-Null
Copy-Item (Join-Path $PackageDir "rpa-project\*") $projectDir -Recurse -Force

Set-Location $projectDir
& $uvTarget init --no-workspace 2>$null
& $uvTarget pip install --no-index --find-links (Join-Path $PackageDir "python-packages") playwright httpx
Write-Host "  套件安裝完成" -ForegroundColor Green

# 3. 設定 Playwright Chromium 路徑（離線，不需下載）
Write-Host "[3/4] 設定 Playwright Chromium..." -ForegroundColor Yellow
$browserSrc = Join-Path $PackageDir "chromium\chromium-1223"
$browserDst = "$env:LOCALAPPDATA\ms-playwright\chromium-1223"
New-Item -ItemType Directory -Force -Path "$env:LOCALAPPDATA\ms-playwright" | Out-Null
if (-not (Test-Path $browserDst)) {
    Copy-Item $browserSrc $browserDst -Recurse -Force
    Write-Host "  Chromium 複製完成" -ForegroundColor Green
} else {
    Write-Host "  Chromium 已存在，跳過" -ForegroundColor Gray
}

# 4. 設定環境變數（讓 Playwright 找到離線 Chromium）
[Environment]::SetEnvironmentVariable("PLAYWRIGHT_BROWSERS_PATH", "$env:LOCALAPPDATA\ms-playwright", "Machine")
$env:PLAYWRIGHT_BROWSERS_PATH = "$env:LOCALAPPDATA\ms-playwright"
Write-Host "[4/4] 環境變數設定完成" -ForegroundColor Green

Write-Host ""
Write-Host "=== 安裝完成 ===" -ForegroundColor Cyan
Write-Host "專案位置：$projectDir" -ForegroundColor White
Write-Host "執行方式：cd C:\rpa-project; uv run python main.py" -ForegroundColor White
Write-Host "請重新開啟 PowerShell 讓 PATH 生效" -ForegroundColor Yellow
