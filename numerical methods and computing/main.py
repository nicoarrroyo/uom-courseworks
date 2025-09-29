import numpy as np
import sys
import matplotlib.pyplot as plt
from Numerical_Quadrature_File import Numerical_Quadrature

## Input the number of finite elements and boundary conditions
Ne = int(input("Enter the number of elements: "))   #  number of finite elements
y0 = np.zeros(1)
y1 = np.zeros(1)
y0[0] = input("Input the boundary condition at x=0: ")  #  BC @ x=0
y1[0] = input("Input the boundary condition at x=1: ")  #  BC @ x=1
print("Input the quadrature rule type:")                #  quadrature rule type
print("   1. Trapezoidal rule")
print("   2. Simpson's rule")
quad_type=int(input())

## Define function to be integrated later
x = np.array(np.linspace(0, 1))
def func(x): return x

## Input the solver type
print("   1. Direct solver (Gaussian elimination)")
print("   2. Jacobi iteration")
sol_type = int(input("Input the solver type: "))
if int(sol_type==2):
   epst = float(input("Input the solution tolerance: "))
   
## Calculate the number of nodes and the element size
N = Ne + 1                  #  number of nodes
h = 1 / Ne                  #  element size 

## Initialize the global matrix and the RHS vector
A = np.zeros(N)             #  coefficient matrix main diagonal
B = np.zeros(N - 1)         #  coefficient matrix sub-diagonal
C = np.zeros(N - 1)         #  coefficient matrix super-diagonal
f = np.zeros(N)             #  RHS vector

## Assemble the element matrices and RHSs
for e in range(Ne):                         #  loop over finite elements
    Ae = np.zeros([2,2])                    #  element coefficient matrix
    fe = np.zeros([2])                      #  element RHS
    for i in range(2):                      #  loop over the nodes in an element
        ##  NUMERICAL QUADRATURE FUNCTION THAT YOU NEED TO WRITE ##
        fe[i] = Numerical_Quadrature(e,i,quad_type,h);  #  element RHS vector contribution
        for j in range(2):                  #  loop over nodes in an element
            Ae[i,j]=(-1)**(i+j)/h           #  element matrix contribution

## Impose the boundary conditions
    if e==0:                                #  the first element at x=0
       Ae[0,0]=1 
       Ae[0,1]=0 
       fe[0]=y0[0];                         #  y=y0 at x=0;
       fe[1]=fe[1]-Ae[1,0]*y0[0]            #  modify the second equation
       Ae[1,0]=0 
    if e==Ne-1:                             #  the last element at x=1
       Ae[1,1]=1 
       Ae[1,0]=0 
       fe[1]=y1[0]                          #  y=y1 at x=1 
       fe[0]=fe[0]-Ae[0,1]*y1[0]            #  modify the second equation
       Ae[0,1]=0 

## Transfer the element matrix and the element RHS to global data structures
    A[e]=A[e]+Ae[0,0]                       #  diagonal element Ae[0,0]
    A[e+1]=A[e+1]+Ae[1,1]                   #  diagonal element Ae[1,1]
    B[e]=Ae[1,0]                            #  sub diagonal element Ae[1,0]
    C[e]=Ae[0,1]                            #  super diagonal element Ae[0,1] 
    f[e]=f[e]+fe[0]                         #  rhs element fe[0]
    f[e+1]=f[e+1]+fe[1]                     #  rhs element fe[1]

## Solve the linear system
if(sol_type==1):       #  direct solver
   from Gaussian_Elimination_File import Gaussian_Elimination
   ## GAUSSIAN ELIMINATION FUNCTION FROM LAB 1 ##
   x = Gaussian_Elimination(A,B,C,f)
elif(sol_type==2):       #  Jacobi iteration
   from Jacobi_Iteration_File import Jacobi_Iteration
   x0 = np.zeros(N)
   ## JACOBI METHOD FUNCTION THAT YOU NEED TO WRITE ##
   [x,rnk,iter] = Jacobi_Iteration(A,B,C,f,x0,epst)   
   ## ----------------------------------------------------------------------------- ##
   print("Method converged in ",iter," iterations")
   print("Norm of the final residual %.6E" % rnk)
else:
   print("Invalid solver type")

## Plot the solution
xx=np.arange(0,1.0001,h)                   #  finite element point
plt.plot(xx,x,'b',linewidth=1.5)           #  plot the solution
plt.xlabel("x")                            #  label x-axis
plt.ylabel("yh(x)")                        #  label y-axis

plt.title('Finite element solution')       #  figure title
plt.xlim((-0.05,1.05))                     #  x-axis limits
plt.ylim((min(x)-0.5,max(x)+0.5))          #  y-axis limits

def Numerical_Quadrature(e, i, quad_type, h):
    # e is the current element index
    # i is the node index (between 1 and 2)
    # quad_type can be either simpson or trapezoidal rule
    # h is the element size
    
    x[i] = (i-1)*h
    x[i+1] = i*h
    
    I = ((x[i+1]-x[i])/2)*(func(x[i])*phi*x[i] + func(x[i+1])*phi*x[i+1])
    return I

def phi(x, i, j):
    if x == x[i]:
        phi = 1
    elif x[j] != x[i]:
        phi = 0
    else:
        phi = x
    return phi


# nico does NOT know :/






















