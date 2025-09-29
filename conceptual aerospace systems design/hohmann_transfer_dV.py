import math

# Given parameters
m0 = 200  # kg, initial spacecraft mass
Isp = 300  # s, specific impulse
g0 = 9.81  # m/s^2, gravitational acceleration at Earth's surface
mu = 3.986*10**5  # m^3/s^2, Earth's gravitational parameter
R_earth = 6371  # km, Earth's radius

# Helper function to calculate circular orbital velocity
def circular_velocity(r):
    return math.sqrt(mu / r)

# Delta-v calculation function for Hohmann transfers
def hohmann_transfer_delta_v(r1, r2):
    # Initial and transfer orbit velocities
    v1 = circular_velocity(r1)  # velocity at initial circular orbit
    v2 = circular_velocity(r2)  # velocity at final circular orbit
    a_transfer = ((2 * R_earth) + r1 + r2) / 2
    
    v_transfer1 = math.sqrt(mu * ((2 / r1 ) - (1 / a_transfer)))  # velocity at initial point in transfer orbit
    v_transfer2 = math.sqrt(mu * ((2 / r2 ) - (1 / a_transfer)))  # velocity at initial point in transfer orbit
    delta_v1 = abs(v_transfer1 - v1)  # delta-v for first burn
    delta_v2 = abs(v2 - v_transfer2)  # delta-v for second burn
    return delta_v1 + delta_v2

# Step 1: 1000 km to 800 km
r1_1000km = (36000 + R_earth)  # kilometers
r2_800km = (39000 + R_earth)  # kilometers
delta_v_1000_to_800 = hohmann_transfer_delta_v(r1_1000km, r2_800km)*10**3 # m/s

# Step 2: 800 km to 600 km
r1_800km = (800 + R_earth)*10**3  # meters
r2_600km = (600 + R_earth)*10**3  # meters
delta_v_800_to_600 = hohmann_transfer_delta_v(r1_800km, r2_600km)

# Step 3: 600 km circular to 600x200 km elliptical
# Initial circular orbit at 600 km, target orbit with apogee 600 km and perigee 200 km
r1_600km = (600 + R_earth)*10**3  # meters
r_perigee_200km = (200 + R_earth)*10**3  # meters

# Current velocity in the circular orbit at 600 km
v_initial_600km = circular_velocity(r1_600km)

# Velocity at apogee of elliptical orbit (600 km) with perigee 200 km
a_transfer = ((2 * R_earth) + r1_600km + r_perigee_200km) / 2
v_apogee_600x200km = math.sqrt(mu * ((2 / r1_600km ) - (1 / a_transfer)))

# Delta-v required to go from 600 km circular to 600x200 km elliptical
delta_v_600_to_600x200 = abs(v_initial_600km - v_apogee_600x200km)

# Total delta-v
total_delta_v = delta_v_1000_to_800 + delta_v_800_to_600 + delta_v_600_to_600x200

# Step 4: Calculate fuel mass required using the rocket equation
# Specific impulse to effective exhaust velocity
ve = Isp * g0  # m/s
# Fuel mass needed based on the total delta-v
fuel_mass = m0 * (1 - math.exp(-total_delta_v / ve))

print("total delta v : ", round(total_delta_v, 3), " [m/s]")
print("total mass: ", round(fuel_mass, 3), " [kg]")

delta_v_1000_to_800, delta_v_800_to_600, delta_v_600_to_600x200, total_delta_v, fuel_mass