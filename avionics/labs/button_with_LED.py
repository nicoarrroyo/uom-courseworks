import time
import board
import digitalio

led = digitalio.DigitalInOut(board.GP10)
led.direction = digitalio.Direction.OUTPUT

button = digitalio.DigitalInOut(board.GP15)
button.switch_to_input(pull=digitalio.Pull.DOWN)

button_timer = time.monotonic()
update_period = 0.01

while True:
    if time.monotonic() > (button_timer+update_period):
        button_timer = time.monotonic()
        buttonPressed = button.value
        if buttonPressed:
            led.value = True
        else:
            led.value = False
