import numpy as np
import matplotlib.pyplot as plt

am1 = np.genfromtxt(
    'mazars/results/mazars_avg/mazars_avg_82.csv', delimiter=',', skip_header=1)
am2 = np.genfromtxt(
    'mazars/results/mazars_avg/mazars_avg_164.csv', delimiter=',', skip_header=1)
am3 = np.genfromtxt(
    'mazars/results/mazars_avg/mazars_avg_328.csv', delimiter=',', skip_header=1)
am4 = np.genfromtxt(
    'mazars/results/mazars_avg/mazars_avg_656.csv', delimiter=',', skip_header=1)

lm1 = np.genfromtxt(
    'mazars/results/mazars_local/mazars_local_82.csv', delimiter=',', skip_header=1)
lm2 = np.genfromtxt(
    'mazars/results/mazars_local/mazars_local_164.csv', delimiter=',', skip_header=1)
lm3 = np.genfromtxt(
    'mazars/results/mazars_local/mazars_local_328.csv', delimiter=',', skip_header=1)
lm4 = np.genfromtxt(
    'mazars/results/mazars_local/mazars_local_656.csv', delimiter=',', skip_header=1)

plt.plot(am1[:, 0], am1[:, 1], '--', label='average mesh 1')
plt.plot(am2[:, 0], am2[:, 1], '--', label='average mesh 2')
plt.plot(am3[:, 0], am3[:, 1], '--', label='average mesh 3')
plt.plot(am4[:, 0], am4[:, 1], '--', label='average mesh 4')
plt.plot(lm1[:, 0], lm1[:, 1], '-', label='local mesh 1')
plt.plot(lm2[:, 0], lm2[:, 1], '-', label='local mesh 2')
plt.plot(lm3[:, 0], lm3[:, 1], '-', label='local mesh 3')
plt.plot(lm4[:, 0], lm4[:, 1], '-', label='local mesh 4')
plt.legend()
plt.xlabel('time [s]')
plt.ylabel('reaction')
plt.show()
