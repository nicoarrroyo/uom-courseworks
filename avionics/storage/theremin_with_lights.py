# Write your code here :-)

import time
import board
from analogio import AnalogIn
import pwmio
import digitalio
import random

led_red = digitalio.DigitalInOut(board.GP17)
led_red.direction = digitalio.Direction.OUTPUT
led_yellow1 = digitalio.DigitalInOut(board.GP10)
led_yellow1.direction = digitalio.Direction.OUTPUT
led_yellow2 = digitalio.DigitalInOut(board.GP6)
led_yellow2.direction = digitalio.Direction.OUTPUT
led_green1 = digitalio.DigitalInOut(board.GP2)
led_green1.direction = digitalio.Direction.OUTPUT
led_green2 = digitalio.DigitalInOut(board.GP17)
led_green2.direction = digitalio.Direction.OUTPUT

potentiometer = AnalogIn(board.A2)

buzzer = pwmio.PWMOut(board.GP20, variable_frequency=True)
duty = 32768

update_period = 0.01
buzzer_timer = time.monotonic()
Amax = (2**16) - 1
Vmin = 0.04
Vmax = 5

while True:
    if time.monotonic() > (buzzer_timer+update_period):
        buzzer_timer = time.monotonic()
        buzzer.duty_cycle = duty
        V = potentiometer.value*(Vmax-Vmin)/(Amax)
        buzzer.frequency = int(1000*(Vmin + V))
        print((V,))
        print(int(V))
        print(buzzer.frequency)
        if V > 3:
            led_red.value = True
            led_yellow1.value = True
            led_yellow2.value = True
            led_green1.value = True
            led_green2.value = True
        elif V < 3 and V > 2.3:
            led_red.value = True
            led_yellow1.value = True
            led_yellow2.value = True
            led_green1.value = True
            led_green2.value = False
        elif V < 2.3 and V > 1.6:
            led_red.value = True
            led_yellow1.value = True
            led_yellow2.value = True
            led_green1.value = False
            led_green2.value = False
        elif V < 1.6 and V > 0.9:
            led_red.value = True
            led_yellow1.value = True
            led_yellow2.value = False
            led_green1.value = False
            led_green2.value = False
        elif V < 0.9 and V > 0.5:
            led_red.value = True
            led_yellow1.value = False
            led_yellow2.value = False
            led_green1.value = False
            led_green2.value = False
        else:
            led_red.value = False
            led_yellow1.value = False
            led_yellow2.value = False
            led_green1.value = False
            led_green2.value = False
