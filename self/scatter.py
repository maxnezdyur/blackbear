import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import sys

# Get from name from sys.argv
if len(sys.argv) > 1:
    filename = sys.argv[1]
else:
    # report error
    print('Usage: python3 scatter.py <filename>')
    sys.exit(1)


plt.style.use('fivethirtyeight')


def read_data():
    data = np.genfromtxt(filename, delimiter=',', skip_header=1)
    x_values = data[1:, 0]
    y_values = data[1:, 1]
    labels = np.genfromtxt(filename, delimiter=',', dtype=str, max_rows=1)
    x_label =labels[0]
    y_label = labels[1]
    return (x_values, y_values), (x_label, y_label)



def animate(i):
    data, labels = read_data()
    plt.cla()
    plt.xlabel(labels[0])
    plt.ylabel(labels[1])
    plt.plot(data[0], data[1])


ani = FuncAnimation(plt.gcf(), animate, interval=500)


plt.tight_layout()
plt.show()
