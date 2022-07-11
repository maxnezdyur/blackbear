import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import sys


plt.style.use('fivethirtyeight')


def read_data(filename):
    data = np.genfromtxt(filename, delimiter=',', skip_header=1)
    x_values = data[1:, 0]
    y_values = data[1:, 1]
    labels = np.genfromtxt(filename, delimiter=',', dtype=str, max_rows=1)
    x_label =labels[0]
    y_label = labels[1]
    dict_data = {'x': x_values, 'y': y_values, 'x_label': x_label, 'y_label': y_label}
    return dict_data


a_m1 = read_data('/Users/nezdmn-mac/projects/blackbear/self/data/test_damage/avg_m1.csv')
a_m2 = read_data('/Users/nezdmn-mac/projects/blackbear/self/data/test_damage/avg_m2.csv')

l_m1 = read_data('/Users/nezdmn-mac/projects/blackbear/self/data/test_damage/local_m1.csv')
l_m2 = read_data('/Users/nezdmn-mac/projects/blackbear/self/data/test_damage/local_m2.csv')

plt.plot(a_m1['x'], a_m1['y'], label='Average M1')
plt.plot(a_m2['x'], a_m2['y'], label='Average M2')
plt.plot(l_m1['x'], l_m1['y'], label='Local M1')
plt.plot(l_m2['x'], l_m2['y'], label='Local M2')
plt.xlabel(a_m1['x_label'])
plt.ylabel(a_m1['y_label'])
plt.title("Force Reaction At Displacement Controlled End")
plt.legend()
plt.show()