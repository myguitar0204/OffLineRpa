import httpx
from playwright.sync_api import sync_playwright

OLLAMA_URL = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "gemma4:12b"


def ask_gemma(prompt: str) -> str:
    resp = httpx.post(
        OLLAMA_URL,
        json={"model": OLLAMA_MODEL, "prompt": prompt, "stream": False},
        timeout=120,
    )
    return resp.json()["response"]


def run_rpa():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        page = browser.new_page()

        # 修改為你的內網網址
        page.goto("http://your-intranet-url")

        # 等待 iframe 載入
        page.wait_for_selector("iframe#main-frame")

        # 進入 iframe
        frame = page.frame_locator("iframe#main-frame")

        # === 在此填入你的 RPA 步驟 ===
        # frame.locator("input[name='username']").fill("帳號")
        # frame.locator("input[name='password']").fill("密碼")
        # frame.locator("button[type='submit']").click()

        page.wait_for_timeout(2000)
        browser.close()


if __name__ == "__main__":
    run_rpa()
