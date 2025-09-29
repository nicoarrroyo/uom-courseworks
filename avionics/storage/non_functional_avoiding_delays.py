import time
import board
import digitalio

# defining inputs and outputs
led_red = digitalio.DigitalInOut(board.GP2)
led_red.direction = digitalio.Direction.OUTPUT
led_green = digitalio.DigitalInOut(board.GP6)
led_green.direction = digitalio.Direction.OUTPUT

button = digitalio.DigitalInOut(board.GP14)
button.switch_to_input(pull=digitalio.Pull.DOWN)

# led blink rates
led_slow = 0.7
led_fast = 0.1
led_currentRate = led_slow

# led and button timers
led_timer = time.monotonic()
button_timer = time.monotonic()

led_red_on = False
led_green_on = False

while True:
    buttonPressed = button.value
    if time.monotonic() > (led_timer+led_currentRate):
        led_timer = time.monotonic()
        if led_red_on:
            led_red_on = False
            led_green_on = True
        else:
            led_red_on = True
            led_green_on = False
        led_red.value = led_red_on
        led_green.value = led_green_on

    if buttonPressed:
        button_timer = time.monotonic()
        led_red.value = False
        led_green.value = False
        time.sleep(3)
    if time.monotonic() > (button_timer + 5):
        led_currentRate = led_slow


