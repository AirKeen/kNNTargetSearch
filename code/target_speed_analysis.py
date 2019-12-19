import matplotlib.pyplot as plt
import pandas as pd
import pylatex as ptx

data1 = pd.read_excel('../data/a_rep_tracking_performance_long.xlsx')
data2 = pd.read_excel('../data/c_rep_tracking_performance_long.xlsx')

data3 = pd.read_excel('../data/a_rep_pso_response_long.xlsx')
data4 = pd.read_excel('../data/c_rep_pso_response_long.xlsx')

show_tracking = True
show_response = True

iterations = 100000
plt.figure()

if show_tracking:
    ks = [10, 15, 20, 30, 40, 49]
    for k in ks:
        vel_column = 'k' + str(k)
        if k == 10:
            colour = 'tab:blue'
        elif k == 15:
            colour = 'tab:cyan'
        elif k == 20:
            colour = 'tab:green'
        elif k == 30:
            colour = 'tab:olive'
        elif k == 40:
            colour = 'tab:orange'
        else:
            colour = 'tab:red'

        plt.plot(data1['V'], data1[vel_column]/iterations, label='$k = $' + str(k), color=colour)
        plt.plot(data2['V'], data2[vel_column]/iterations, linestyle='dashed', color=colour)

    plt.xlabel('Target Speed')
    plt.title('Tracking Performance')

    plt.ylabel('Percentage of Time on Target')
    plt.legend(loc='upper right', frameon=False)
    plt.show()

if show_response:
    ks = [10, 15, 20, 30, 40, 49]
    for k in ks:
        vel_column = 'k' + str(k)
        if k == 10:
            colour = 'tab:blue'
        elif k == 15:
            colour = 'tab:cyan'
        elif k == 20:
            colour = 'tab:green'
        elif k == 30:
            colour = 'tab:olive'
        elif k == 40:
            colour = 'tab:orange'
        else:
            colour = 'tab:red'

        plt.plot(data1['V'], data3[vel_column], label='$k = $' + str(k), color=colour)
        plt.plot(data2['V'], data4[vel_column], linestyle='dashed', color=colour)

    plt.xlabel('Target Speed')
    plt.title('System Response')

    plt.ylabel('Cumulative Velocity Fluctuation Magnitude')
    plt.legend(loc='upper right', frameon=False)
    plt.show()
