import numpy as np
import timeit
import matplotlib.pyplot as p

# functions
def thomas_algorithm(A, B, C, f):
    n = len(f)
    a = A.copy()
    b = B.copy()
    c = C.copy()
    d = f.copy()
    
    # forward elimination
    for i in range(1, n):
        m = a[i-1]/b[i-1]
        b[i] -= m*c[i-1]
        d[i] -= m*d[i-1]
    
    # back substitution
    x = [0]*n
    x[-1] = d[-1]/b[-1]
    for j in range(n-2, -1, -1):
        x[j] = (d[j]-(c[j]*x[j+1]))/b[j]
    return x
# calculating execution time from input variable n
def find_exec_time(n):
    A = [-1]*(n-1)
    B = [2]*n
    C = [-1]*(n-1)
    
    exec_times = []
    t_start = timeit.default_timer()
    thomas_algorithm(A, B, C, f)
    exec_time = timeit.default_timer() - t_start
    exec_times.append(exec_time)
    return exec_time

# coefficients
n = 10
A = [-1]*(n-1)
B = [2]*n
C = [-1]*(n-1)

# LHS function matrix
f = np.ones(n)

solution_thomas = thomas_algorithm(A, B, C, f)
solution_thomas_rounded = np.round(solution_thomas, 2)
coeff_matrix = np.diag(B) + np.diag(A, -1) + np.diag(C, 1)
solution_numpy = np.linalg.solve(coeff_matrix, f)

print("Thomas Algorithm solution:", solution_thomas_rounded)
print("numpy solver solution:", solution_numpy)

matrix_sizes = np.array(np.linspace(10**6, 10**8, 5))
matrix_sizes_unrounded = matrix_sizes.tolist()
sizes_rounded = np.round(matrix_sizes_unrounded).astype(int)

exec_times = [find_exec_time(n) for n in sizes_rounded]

# plot
p.plot(sizes_rounded, exec_times, marker = 'v')
p.grid()
p.title("Thomas Algorithm Execution Time vs Problem Size")
p.xlabel("Problem Size n")
p.ylabel("Execution Time in sec")
p.show()
