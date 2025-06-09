# pyinstaller --noconsole --onefile C:\Users\duke\Documents\Python\test\mouse_autoclick_hwnd.py
import sys
import time
import win32gui, win32con, win32api
import keyboard, pyautogui
from random import randint
from datetime import datetime

from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QPushButton, QLineEdit, QVBoxLayout, QFrame, QSizePolicy  
from PyQt5.QtCore import QThread, pyqtSignal, QTimer, QPoint, Qt
from PyQt5.QtGui import QPainter, QRadialGradient, QColor, QBrush


class ClickWorker(QThread):
    update_status = pyqtSignal(str, str)
    update_click_time = pyqtSignal(str)
    flash_click = pyqtSignal(int, int)

    interval = 10.0
    stop_flag = False
    hwnd = None
    area_width = 300
    area_height = 100

    def run(self):
        self.stop_flag = False
        self.update_status.emit("실행 중...", "green")
        while not self.stop_flag:
            if self.hwnd:
                x = randint(10, self.area_width - 10)
                y = randint(10, self.area_height - 10)
                lParam = win32api.MAKELONG(x, y)
                win32gui.PostMessage(self.hwnd, win32con.WM_LBUTTONDOWN, win32con.MK_LBUTTON, lParam)
                win32gui.PostMessage(self.hwnd, win32con.WM_LBUTTONUP, None, lParam)
                now = datetime.now().strftime("%H:%M:%S")
                self.update_click_time.emit(f"마지막 클릭: {now} | 위치: ({x}, {y})")
                self.flash_click.emit(x, y)

            waited = 0
            while waited < self.interval and not self.stop_flag:
                time.sleep(0.1)
                waited += 0.1
        self.update_status.emit("정지됨", "blue")

    def stop(self):
        self.stop_flag = True


class ClickArea(QFrame):
    def __init__(self):
        super().__init__()
        #self.setFixedSize(300, 100)
        # 대신 최소 크기 정도만 설정해주고, layout이 확장하도록
        self.setMinimumSize(100, 80)
        self.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.setStyleSheet("background-color: lightgray; border: 1px solid #666;")
        self.animations = []
        self.anim_timer = QTimer()
        self.anim_timer.timeout.connect(self.update_animations)
        self.anim_timer.start(30)

    def add_flash(self, x, y):
        if len(self.animations) >= 3:
            self.animations.pop(0)
        self.animations.append({'pos': (x, y), 'radius': 10, 'opacity': 255})

    def update_animations(self):
        for anim in self.animations:
            anim['radius'] += 3       #프레임당 커지는 속도. 숫자줄이면 작게
            anim['opacity'] -= 10     #투명해지는 속도. 숫자줄이면 더 느려짐 
        self.animations = [a for a in self.animations if a['opacity'] > 0 and a['radius']<40]
        self.update()

    def paintEvent_org(self, event):
        super().paintEvent(event)
        qp = QPainter(self)
        for anim in self.animations:
            x, y = anim['pos']
            radius = anim['radius']
            opacity = anim['opacity']
            grad = QRadialGradient(QPoint(x, y), radius)
            grad.setColorAt(0.0, QColor(0, 255, 255, min(opacity, 200)))  # 중심: 형광파랑
            grad.setColorAt(1.0, QColor(255, 192, 203, 0))                # 바깥: 투명 분홍
            qp.setBrush(QBrush(grad))
            qp.setPen(Qt.NoPen)
            qp.drawEllipse(QPoint(x, y), radius, radius)
    def paintEvent(self, event):
        super().paintEvent(event)
        qp = QPainter(self)
        for anim in self.animations:
            x, y = anim['pos']
            radius = anim['radius']
            opacity = anim['opacity']

            # 반지름에 따라 색상 변화 (HSV → RGB 변환)
            hue = (radius * 4) % 360  # HSV 색상각도 회전 (0~360), 곱하는 숫자변경하면 더 다양한색감감
            hue = (radius * 10 + randint(0, 100)) % 360
            color_center = QColor.fromHsv(hue, 255, 255, min(opacity, 220))
            color_edge = QColor.fromHsv((hue + 60) % 360, 100, 255, 0)

            grad = QRadialGradient(QPoint(x, y), radius)
            grad.setColorAt(0.0, color_center)
            grad.setColorAt(1.0, color_edge)

            qp.setBrush(QBrush(grad))
            qp.setPen(Qt.NoPen)
            qp.drawEllipse(QPoint(x, y), radius, radius)


class App(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("백그라운드 PyQt 클릭기")
        self.setGeometry(300, 300, 400, 380)

        layout = QVBoxLayout(self)
        layout.addWidget(QLabel("클릭 간격 (초):"))

        self.interval_input = QLineEdit("10")
        layout.addWidget(self.interval_input)

        self.start_button = QPushButton("시작")
        self.start_button.clicked.connect(self.start_worker)
        layout.addWidget(self.start_button)

        self.stop_button = QPushButton("정지")
        self.stop_button.clicked.connect(self.stop_worker)
        layout.addWidget(self.stop_button)

        self.status_label = QLabel("정지됨")
        self.status_label.setStyleSheet("color: blue;")
        layout.addWidget(self.status_label)

        self.last_click_label = QLabel("마지막 클릭: -")
        layout.addWidget(self.last_click_label)

        self.mouse_pos_label = QLabel("마우스 위치: (x, y)")
        layout.addWidget(self.mouse_pos_label)

        self.click_area = ClickArea()
        layout.addWidget(self.click_area)

        self.worker = ClickWorker()
        self.worker.update_status.connect(self.set_status)
        self.worker.update_click_time.connect(self.set_last_click_time)
        self.worker.flash_click.connect(self.click_area.add_flash)
        self.worker.hwnd = int(self.click_area.winId())

        self.timer = QTimer()
        self.timer.timeout.connect(self.update_mouse_position)
        self.timer.start(300)

        keyboard.add_hotkey("ctrl+shift+s", self.toggle_worker)

    def update_mouse_position(self):
        x, y = pyautogui.position()
        self.mouse_pos_label.setText(f"마우스 위치: ({x}, {y})")

    def set_status(self, msg, color):
        self.status_label.setText(msg)
        self.status_label.setStyleSheet(f"color: {color};")

    def set_last_click_time(self, text):
        self.last_click_label.setText(text)

    def start_worker(self):
        if not self.worker.isRunning():
            try:
                self.worker.interval = float(self.interval_input.text())
                self.worker.start()
            except ValueError:
                self.set_status("유효한 간격을 입력하세요", "red")

    def stop_worker(self):
        if self.worker.isRunning():
            self.worker.stop()

    def toggle_worker(self):
        if self.worker.isRunning():
            self.stop_worker()
        else:
            self.start_worker()

    def closeEvent(self, event):
        keyboard.unhook_all_hotkeys()
        self.worker.stop()
        event.accept()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = App()
    window.show()
    sys.exit(app.exec_())
