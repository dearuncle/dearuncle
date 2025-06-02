import sys
import random
import time
from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QPushButton, QLineEdit, QVBoxLayout
from PyQt5.QtCore import QThread, pyqtSignal
import pyautogui

# 사각형 영역 설정 (좌상단 x,y, 우하단 x,y)
RECT_X1, RECT_Y1 = 300, 300
RECT_X2, RECT_Y2 = 1000, 700

class Worker(QThread):
    update_status = pyqtSignal(str, str)  # 메시지, 색상
    stop_flag = False
    interval = 60.0

    def run(self):
        self.stop_flag = False
        self.update_status.emit("실행 중...", "green")
        while not self.stop_flag:
            x = random.randint(RECT_X1, RECT_X2)
            y = random.randint(RECT_Y1, RECT_Y2)

            if random.choice(['click', 'keypress']) == 'click':
                pyautogui.click(x, y)
            else:
                pyautogui.press('shift')

            time.sleep(self.interval)
        self.update_status.emit("정지됨", "blue")

    def stop(self):
        self.stop_flag = True


class App(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("화면보호기 방지기 (PyQt5)")

        self.layout = QVBoxLayout()
        self.setLayout(self.layout)

        self.interval_label = QLabel("클릭 간격 (초):")
        self.layout.addWidget(self.interval_label)

        self.interval_input = QLineEdit()
        self.interval_input.setText("60")
        self.layout.addWidget(self.interval_input)

        self.start_button = QPushButton("시작")
        self.start_button.clicked.connect(self.start_worker)
        self.layout.addWidget(self.start_button)

        self.stop_button = QPushButton("정지")
        self.stop_button.clicked.connect(self.stop_worker)
        self.layout.addWidget(self.stop_button)

        self.status_label = QLabel("정지됨")
        self.status_label.setStyleSheet("color: blue;")
        self.layout.addWidget(self.status_label)

        self.worker = Worker()
        self.worker.update_status.connect(self.set_status)

    def start_worker(self):
        if not self.worker.isRunning():
            try:
                interval = float(self.interval_input.text())
                self.worker.interval = interval
                self.worker.start()
            except ValueError:
                self.set_status("유효한 간격(초)을 입력하세요", "red")

    def stop_worker(self):
        if self.worker.isRunning():
            self.worker.stop()

    def set_status(self, message, color):
        self.status_label.setText(message)
        self.status_label.setStyleSheet(f"color: {color};")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = App()
    window.show()
    sys.exit(app.exec_())
