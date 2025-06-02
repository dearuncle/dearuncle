import tkinter as tk
import threading
import time
import random
import pyautogui

# 사각형 영역 설정 (좌상단 x,y, 우하단 x,y)
RECT_X1, RECT_Y1 = 300, 300
RECT_X2, RECT_Y2 = 1000, 700

# 동작 제어 변수
running = False

def prevent_screensaver(interval):
    while running:
        # 랜덤 위치 설정
        x = random.randint(RECT_X1, RECT_X2)
        y = random.randint(RECT_Y1, RECT_Y2)

        # 무작위로 클릭 또는 키 입력 선택
        if random.choice(['click', 'keypress']) == 'click':
            pyautogui.click(x, y)
        else:
            pyautogui.press('shift')  # 키 입력은 영향 적은 키 사용

        time.sleep(interval)

def start():
    global running
    if not running:
        try:
            interval = float(interval_entry.get())
            running = True
            status_label.config(text="실행 중...", fg="green")
            threading.Thread(target=prevent_screensaver, args=(interval,), daemon=True).start()
        except ValueError:
            status_label.config(text="유효한 간격(초)을 입력하세요", fg="red")

def stop():
    global running
    running = False
    status_label.config(text="정지됨", fg="blue")

# GUI 생성
root = tk.Tk()
root.title("화면보호기 방지기")

tk.Label(root, text="클릭 간격 (초):").pack(pady=5)
interval_entry = tk.Entry(root)
interval_entry.insert(0, "60")
interval_entry.pack()

tk.Button(root, text="시작", command=start).pack(pady=5)
tk.Button(root, text="정지", command=stop).pack(pady=5)

status_label = tk.Label(root, text="정지됨", fg="blue")
status_label.pack(pady=10)

root.mainloop()
