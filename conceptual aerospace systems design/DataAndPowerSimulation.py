import numpy as np
import matplotlib.pyplot as plt

# Definitions
# Payload-specific parameters
payloads = {
    'EO': {'power_imaging': 27.26, 'power_idle': 15.1, 'data_output': 3532.9},
    'ADCS': {'power_peak': 4.16, 'power_idle': 0.998, 'data_output': 1000 / 24},
    'SOAR': {'power': 5, 'data_output': 1000 / 24}
}

# Miscellaneous parameters
hours_per_day = 24
days = 40
testing_schedule = ['EO', 'EO', 'SOAR', 'SOAR', 'SOAR', 'EO', 'EO', 'ADCS', 'ADCS', 'EO']

# Simulation Initialization
power_draw = np.zeros(days)
data_generated = np.zeros(days)
data_max = 1000 * 1000  # 1 Tb total storage
data_min = 128 * 1000   # 128 Gb for MIMIR OS
data_used = np.zeros(days)
data_used[0] = data_min
revisit_period = 10  # days between data downlinks
downlink_day = 0

# Simulation Loop
for day in range(days):
    if day < 10:
        day_sched = day
    elif 10 <= day < 20:
        day_sched = day - 10
    elif 20 <= day < 30:
        day_sched = day - 20
    elif 30 <= day < 40:
        day_sched = day - 30

    payload = payloads[testing_schedule[day_sched]]

    if testing_schedule[day_sched] == 'EO':
        daily_power = (payload['power_imaging'] * 0.2 + payload['power_idle'] * 0.8) * hours_per_day
    elif testing_schedule[day_sched] == 'ADCS':
        daily_power = (payload['power_peak'] * 0.5 + payload['power_idle'] * 0.5) * hours_per_day
    else:  # SOAR
        daily_power = payload['power'] * hours_per_day

    power_draw[day] = daily_power
    data_generated[day] = payload['data_output'] * hours_per_day

    if (day + 1) % revisit_period == 0:
        data_used[day] = data_min
        downlink_day = day
    else:
        data_used[day] = data_min + np.sum(data_generated[downlink_day:day + 1])

# Plotting Results
plt.figure(figsize=(10, 8))

# Power Draw Plot
plt.subplot(2, 1, 1)
plt.bar(range(1, days + 1), power_draw)
plt.grid(True)
plt.title(f'Daily Power Draw Over {days} Days')
plt.xlabel('Day')
plt.ylabel('Power Draw (Wh)')
plt.xticks(range(0, days + 1, 5))
plt.axhline(38 * 24, color='b', label='Power Generated')
plt.legend(loc='best')

# Data Generation and Usage Plot
plt.subplot(2, 1, 2)
plt.plot(range(1, days + 1), np.cumsum(data_generated), '-o', label='Total Data Generated')
plt.plot(range(1, days + 1), data_used, '-s', label='Storage Used')
plt.axhline(data_max, color='r', label='Max. Data Storage')
plt.axhline(data_min, color='b', label='Storage for MIMIR OS')
plt.ylim(0, None)
plt.grid(True)
plt.title(f'Data Generated and Storage Used Over {days} Days')
plt.xlabel('Day')
plt.ylabel('Data (Mb)')
plt.legend(loc='best')

plt.tight_layout()
plt.show()
