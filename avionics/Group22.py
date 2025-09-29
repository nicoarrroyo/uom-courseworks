# Necessary imports
import board
import pwmio
import time
import analogio
import busio
import sdcardio
import storage
import digitalio
import re
import sys
import random
import os

# Define analogue inputs
rpmanalog = analogio.AnalogIn(board.A0)
voltageanalog = analogio.AnalogIn(board.A1)
currentanalog = analogio.AnalogIn(board.A2)

# Button and LED
button = digitalio.DigitalInOut(board.GP15)
button.switch_to_input(pull=digitalio.Pull.DOWN)
led = digitalio.DigitalInOut(board.GP10)
led.direction = digitalio.Direction.OUTPUT

# Buzzer
buzzer = pwmio.PWMOut(board.GP9, variable_frequency=True)
buzzer_duty = 32768
low_voltage_tone = 250  # Low voltage warning buzzer frequency
high_current_tone = 2000  # High current warning buzzer frequency
high_current_counter = 0  # Reset counter checking for high current

# UART Load Cell initialisation
loadCellUART = busio.UART(board.GP12, board.GP13, baudrate=9600, timeout=0.05)

# Electronic Speed Controller (ESC) variables
# {1g} Motor control PWM signal shall be 50 Hz
ESCfrequency = 50  # Hz
ESC_input = pwmio.PWMOut(board.GP21, frequency=ESCfrequency)
ESC_input.duty_cycle = 0

# Arrays to define throttle and airspeed ranges
throttle = [10, 20, 30, 40, 50, 60, 70, 80]
speeds = [8, 10, 12]

# SD Card
spi = busio.SPI(board.GP18, MOSI=board.GP19, MISO=board.GP16)
cs = board.GP17

sdcard = sdcardio.SDCard(spi, cs)
vfs = storage.VfsFat(sdcard)
storage.mount(vfs, "/sd")

# Functions
# =============

# Convert counts (binary value) to voltage
def count2voltage(V_min, V_max, sensor_counts):
    voltage = (sensor_counts/((2**16)-1))*(V_max-V_min)+V_min
    return voltage

# Convert voltage value to sensor value
def voltage2measurement(sensor_voltage, V_min, V_max, S_min, S_max):
    # take sensor voltage, create linear mapping, between min & max sensor values,
    # and min & max values from the Pico, and offset by the minimum sensor value
    # lab week 5.1 page 2
    measurement = ((sensor_voltage - V_min)*((S_max - S_min)/(V_max - V_min))) + S_min
    return measurement

# {1a} DAS shall measure motor voltage from 0 to 26 volts
def motorVoltage(voltageanalog):
    S_min = 1.79
    S_max = 24.9
    V_min = 0.2
    V_max = 2.91

    counts = voltageanalog.value

    # Convert sensed counts to DAS voltage
    sensor_voltage = count2voltage(V_min, V_max, counts)

    # Convert DAS voltage to measured voltage
    motor_voltage = voltage2measurement(sensor_voltage, V_min, V_max, S_min, S_max)
    return motor_voltage

# {1b} DAS shall measure motor current from 0 to 40 amps
def motorCurrent(currentanalog):
    I_min = 0
    I_max = 40
    V_min = 0
    V_max = 3.3

    I_bias = 1.62
    I_sensitivity = 25  # A/V
    counts = currentanalog.value

    sensor_voltage = count2voltage(I_min, I_max, counts)
    SV_max = (I_max/I_sensitivity) + I_bias
    SV_min = (I_min/I_sensitivity) + I_bias

    current = voltage2measurement(sensor_voltage, V_min, V_max, SV_min, SV_max)
    return current

# {1c} DAS shall measure motor speed from 0 to 12000 RPM
def motorRPM(rpmanalog):
    RPM_min = 0
    RPM_max = 12000
    V_min = 0
    V_max = 5

    RPM_bias = 0
    RPM_sensitivity = 3636  # rpm/V
    counts = rpmanalog.value

    sensor_voltage = count2voltage(RPM_min, RPM_max, counts)
    SV_max = (RPM_max/RPM_sensitivity) + RPM_bias
    SV_min = (RPM_min/RPM_sensitivity) + RPM_bias

    RPM = voltage2measurement(sensor_voltage, V_min, V_max, SV_min, SV_max)
    return RPM

# {1d/e}
def loadcell(loadCellUART):
    # {1i} DAS shall not crash if incoming UART messages are paused/corrupted
    # The try-except makes it so that the program does not crash when a
    # data string is corrupted, 'un-cleanable', or not present

    # Start while loop to continuosly check for messages
    # If a message is missing, try reading again and repeat this
    # process until 5 attempts have been made, in which case [0, 0] is returned
    # as the 'error' value for thrust and torque respectively

    read_attempts = 0
    loadcell_time = time.monotonic()
    loadcell_check_period = 0.1
    while time.monotonic() < (loadcell_time+loadcell_check_period):
        loadcell_time = time.monotonic()
        try:
            data = loadCellUART.readline()
            try:
                rxString = data.decode('ascii')
            except Exception as e:
                data = ("<##, 23.0644, -1.224>")  # mock data
                rxString = data
                decode_error = e

            # Split rxString into 3 indivual strings at each comma
            frame, rxThrust, rxTorque = rxString.split(',')

            # Replace any non-integer, non-decimal point characters
            thrust = float(re.sub("[^0-9.-]", "", rxThrust))
            torque = float(re.sub("[^0-9.-]", "", rxTorque))

            # Produce a cleaned, float list containing thrust and torque
            desired_data = [thrust, torque]
            return desired_data
        except Exception as e:
            # if data is corrupted, return thrust & torque = 0
            read_attempts = read_attempts + 1
            if read_attempts < 5:
                loadcell_time = time.monotonic()
            else:
                return [0, 0]


# {1d} DAS shall measure thrust in Newtons
def motorThrust(loadCellUART):
    # Grab current thrust
    desired_data = loadcell(loadCellUART)
    thrust = desired_data[0]
    return thrust

# {1e} DAS shall measure torque in Newton-meters
def motorTorque(loadCellUART):
    # Grab current Torque
    desired_data = loadcell(loadCellUART)
    torque = desired_data[1]
    return torque

# {1f} DAS will create a PWM motor signal from 1000 to 2000 microseconds
def calcPulseWidth(throttle):
    # Calculate current pulse width
    pw_min = 1000
    pw_max = 2000
    throttle_min = 0
    throttle_max = 100
    throttle_range = throttle_max - throttle_min
    pw_range = pw_max - pw_min

    pulseWidth = ((throttle-throttle_min)*((pw_range)/(throttle_range)))+pw_min
    return pulseWidth

# {1g} 2 Motor control PWM signal shall be 50 Hz
def calcDuty(pulseWidth):
    # Find duty cycle
    dutyFraction = (pulseWidth / 1000000) * ESCfrequency * ((2**16) - 1)
    return dutyFraction

# {2d} DAS shall automatically average all measurements over a 5 second period
def average(value_list):
    sum = 0
    for i in range(frame_start_index, len(value_list)):
        sum = value_list[i] + sum
    average = sum/(len(value_list)-frame_start_index)
    return average

# {4h**} An emergency stop button will be available at all times to cease
# operation by setting the ESC throttle to low/off
def check_emergency_stop():
    button_timer = time.monotonic()
    button_update_period = 0.01
    while True:
        if time.monotonic() > (button_timer+button_update_period):
            button_timer = time.monotonic()
            buttonPressed = button.value
            if buttonPressed:
                ESC_input.duty_cycle = 0
                print("EMERGENCY STOP")
                sys.exit()
            else:
                continue

# {4b} Monitoring message shall be updated at 1 Hz
monitor_period = 1

# Other timer definitions
sample_period = 0.5  # 2 samples per second
averaging_period = 5  # time over which we need to average values
total_sample_time = 10  # total time per throttle setting to take data
discard_period = 2  # discard data collected for 2 seconds after throttle change

t_monitor = time.monotonic()  # time at serial monitoring message output
t_throttle = time.monotonic()  # time at throttle change
t_sample = time.monotonic()  # time at start of sample period
t_speeds = time.monotonic()  # time at airspeed change
sample_update = time.monotonic()  # time at start of each sample data grab
monitor_update = time.monotonic()  # time at start of each serial monitor message output

button_timer = time.monotonic()
button_update_period = 0.01

# Format for serial monitoring message
g = 6  # gap between headers and values
# Define column headers
headers = ["Index", "Airspeed", "Throttle", "Force", "Torque", "RPM", "Power"]
units = ["[-]", "[m/s]", "[%]", "[N]", "[Nm]", "[-]", "[W]"]

# Initialise arrays to be filled
voltage = []
current = []
RPM = []
thrust = []
torque = []

# {2a} DAS will output ESC throttle low/off signal until testing begins
pulseWidth = calcPulseWidth(throttle[0])
duty = int(calcDuty(pulseWidth))
ESC_input.duty_cycle = duty
print("ESC Throttle Low")

# Test to begin running program
choice = input("Press 1 to begin testing, 2 to quit: ")
valid = False
while (not valid):
    if (choice == '1'):
        valid = True
    elif (choice == '2'):
        valid = True
        print("Quitting Program")
        sys.exit()
    else:
        valid = False
        choice = input("Press 1 to begin testing, 2 to quit: ")

# {3e**} Each new file shall have an automatically
# incrementing unique file name (no overwriting)
file_n = 0
file_name = ("GROUP22_data" + str(file_n) + ".csv")
while file_name in os.listdir("/sd/Data Collections"):
    file_n = file_n + 1
    file_name = ("GROUP22_data" + str(file_n) + ".csv")

# {3a} DAS shall create an output file in the .csv format
with open("/sd/Data Collections/" + file_name, "w") as f: f.write("")  # Ensure file is wiped

# {2c**} DAS will perform data collection for airspeeds of 8, 10, and 12 m/s
for i in range(0, len(speeds)):
    print("New Airspeed: ", str(speeds[i]))

    # {4f**} DAS will pause between each airspeed setting and resume after a button press
    go_ahead = False
    button_timer = time.monotonic()
    print("Paused for airspeed change | Press button to give the 'go ahead'")

    # {4g**} DAS will visibly indicate that operation is paused for an airspeed change
    led.value = True

    # {4f**} 2
    while time.monotonic() < (button_timer+button_update_period) and (not go_ahead):
        button_timer = time.monotonic()
        buttonPressed = button.value
        if buttonPressed:
            go_ahead = True
            print("Button Pressed, go ahead for airspeed change")
        elif not buttonPressed:
            go_ahead = False
            button_timer = time.monotonic()

    # {2b} DAS shall automatically collect measurements for motor throttle settings between
    # 10% and 80% full range in 10% increments at each airspeed
    for j in range(0, len(throttle)):
        m_index = 0  # reset serial monitor index
        n = 0  # reset csv file index

        # {3d} Column header line shall be included at the start of the csv file
        with open("/sd/Data Collections/" + file_name, "a") as f:
            f.write("\nIndex, Airspeed, Throttle, Current, Voltage, RPM, Force, Torque\n")
            f.write("[-], [m/s], [-], [A], [V], [-], [N], [Nm]\n")

        # Update pulse width calculation
        pulseWidth = calcPulseWidth(throttle[j])
        duty = int(calcDuty(pulseWidth))
        ESC_input.duty_cycle = duty
        led.value = False

        # {2e} DAS will discard any data in the 2 seconds following a throttle setpoint change
        t_throttle = time.monotonic()
        while time.monotonic() < (t_throttle+discard_period):
            # Reset arrays to be refilled at next throttle setting
            voltage = []
            current = []
            RPM = []
            thrust = []
            torque = []

            print("THROTTLE CHANGE - ALLOW TWO SECONDS")
            time.sleep(2)

        # Print column headers for serial monitoring message
        header_line = "|".join(h.center(len(h)+g) for h in headers)
        unit_line = "|".join(u.center(len(headers[i])+g) for i, u in enumerate(units))
        print(header_line)
        print(unit_line)

        t_sample = time.monotonic()
        t_monitor = time.monotonic()
        while time.monotonic() < (t_sample+total_sample_time):
            # Update pulse width calculation
            pulseWidth = calcPulseWidth(throttle[j])
            duty = int(calcDuty(pulseWidth))
            ESC_input.duty_cycle = duty

            # Data collection (every 0.5 seconds)
            if time.monotonic() > (sample_update+sample_period):
                sample_update = time.monotonic()

                voltage.append(motorVoltage(voltageanalog))
                current.append(motorCurrent(currentanalog))
                RPM.append(motorRPM(rpmanalog))
                thrust.append(motorThrust(loadCellUART))
                torque.append(motorTorque(loadCellUART))

                # {4d**} DAS shall audibly warn the user if the voltage drops below 22V
                if voltage[-1] < 22:
                    buzzer.duty_cycle = buzzer_duty
                    buzzer.frequency = int(low_voltage_tone)
                    time.sleep(0.05)
                    buzzer.duty_cycle = 0
                else:
                    buzzer.duty_cycle = 0

                # {4e**} DAS shall audibly warn the user if the current stays above 20A
                # for more than 10 seconds
                if current[-1] > 20:
                    high_current_counter = high_current_counter + 1
                    if high_current_counter > 20:  # > 20 because 2 samples per second
                        buzzer.duty_cycle = buzzer_duty
                        buzzer.frequency = int(high_current_tone)
                        time.sleep(0.05)
                        buzzer.duty_cycle = 0
                    else:
                        buzzer.duty_cycle = 0
                elif current[-1] < 20 and len(current) > 2:
                    if current[-2] < 20: high_current_counter = 0

                # {2d} Averaging data (every 0.5 seconds after first 5 seconds)
                if time.monotonic() > (t_sample+averaging_period):
                    # Redefine data arrays to only hold previous 5 seconds of data
                    # and find the average value of those 5 seconds

                    # 5 seconds of data is equal to 10 data points

                    # take index from 5 seconds ago
                    if time.monotonic() < (t_sample+averaging_period+0.5):
                        frame_start_index = 0
                    else:
                        frame_start_index = frame_start_index + 1

                    V_avg = average(voltage)
                    I_avg = average(current)
                    RPM_avg = average(RPM)
                    thrust_avg = average(thrust)
                    torque_avg = average(torque)
                    throttle_pw = calcPulseWidth(throttle[j])

                    # {3b} The .csv columns will be:
                    # (i)incrementing sample n, (ii)windspeed, (iii)ESC throttle, (iv)current, (v)voltage, (vi)RPM, (vii)force, (viii)torque
                    with open("/sd/Data Collections/" + file_name, "a") as f:
                        n = n + 1
                        # {3c} One line shall be written per matric test point (shown by \n)
                        f.write("%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f\n" % (n, speeds[i], throttle_pw, I_avg, V_avg, RPM_avg, thrust_avg, torque_avg))

            # {4a} Serial monitoring message shall be output to the user
            if time.monotonic() > (t_monitor+monitor_period):
                t_monitor = time.monotonic()
                # subscript m denotes variable saved for monitoring message
                m_index = m_index + 1
                m_airspeed = speeds[i]
                m_throttle = throttle[j]
                m_force = round(thrust[-1], 3)
                m_torque = round(torque[-1], 3)
                m_RPM = RPM[-1]
                temp_voltage = voltage[-1]
                temp_current = current[-1]
                m_power = round((temp_voltage*temp_current), 1)

                # {4c} The monitoring message shall contain:
                # (i)Airspeed, (ii)ESC throttle %, (iii)force, (iv)torque, (v)RPM, (vi)power
                variables = [m_index, m_airspeed, m_throttle, m_force, m_torque, m_RPM, m_power]
                m = [str(val).center(len(headers[i])+g) for i, val in enumerate(variables)]
                print("|".join(m))

print("END OF DATA COLLECTION")
