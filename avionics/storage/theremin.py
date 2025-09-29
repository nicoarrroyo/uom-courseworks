# Write your code here :-)

import time
import board
from analogio import AnalogIn
import pwmio

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
        buzzer.frequency = int(500*(Vmin + potentiometer.value*(Vmax-Vmin)/(Amax)))
        V = potentiometer.value*(Vmax-Vmin)/(Amax)
        print((V,))
        print(buzzer.frequency)
