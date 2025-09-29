gap = 3

# Define column headers
headers = ["Airspeed", "Throttle", "Force", "Torque", "RPM", "Power"]
units = ["[m/s]", "[%]", "[N]", "[Nm]", "[ ]", "[W]"]

# Print column headers and units
header_line = "|".join(header.center(len(header) + gap) for header in headers)
unit_line = "|".join(unit.center(len(headers[i]) + gap) for i, unit in enumerate(units))

print(header_line)
print(unit_line)

# Define variables
m_airspeed = 8
m_throttle = 20
m_force = 1.754
m_torque = 70.522
m_RPM = 2
m_power = 4

# Print variables
variables = [m_airspeed, m_throttle, m_force, m_torque, m_RPM, m_power]
message = [str(val).center(len(headers[i]) + gap) for i, val in enumerate(variables)]
print("|".join(message))
