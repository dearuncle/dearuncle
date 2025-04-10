from  import webdriver

# Chrome 옵션 설정 (headless 모드 포함 가능)
options = webdriver.ChromeOptions()
options.add_argument('--headless')  # 창 없이 실행 (필요 시 생략 가능)

# 드라이버 실행 (Selenium 3.x에서는 chrome_options 사용!)
driver = webdriver.Chrome(
    executable_path="C:/Windows/System32/chromedriver.exe",
    chrome_options=options
)

# 테스트용 페이지 접속
driver.get("https://www.google.com")
print(driver.title)

driver.quit()
