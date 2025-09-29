import board
import pwmio
import time
import analogio
import busio
import sdcardio
import storage

buzzer = pwmio.PWMOut(board.GP20, variable_frequency=True)
potentiometer = analogio.AnalogIn(board.GP26)

def analogue2tone(inputValue):
    Amin = 0
    Amax = (2**16)-1
    Tmin = 50
    Tmax = 5000
    tone = ((inputValue-Amin)*((Tmax-Tmin)/(Amax-Amin)))+Tmin
    return tone

duty = 32768

period_buzzer = 1
t_buzzer = time.monotonic()

# sd card
spi = busio.SPI(board.GP18, MOSI=board.GP19, MISO=board.GP16)
cs = board.GP17

sdcard = sdcardio.SDCard(spi, cs)
vfs = storage.VfsFat(sdcard)

storage.mount(vfs, "/sd")

def average(value):


while True:
    if time.monotonic() > (t_buzzer + period_buzzer):
        t_buzzer = time.monotonic()
        tone_frequency = analogue2tone(potentiometer.value)
        buzzer.duty_cycle = duty
        buzzer.frequency = int(tone_frequency)
        with open("/sd/thing.csv", "w") as f:
            with open("/sd/thing.csv", "a") as f:
                f.write("%.1f\n" % (potentiometer.value))
            with open("/sd/thing.csv", "r") as f:
                print(f.read())
