import matplotlib.pyplot as plt
import pandas as pd
import pylatex as ptx

data1 = pd.read_csv('../data/a_rep_v_line_counter_v20.csv', header=None)
data2 = pd.read_csv('../data/c_rep_v_line_counter_v20.csv', header=None)
data3 = pd.read_csv('../data/a_rep_v_line_counter_v25.csv', header=None)
data4 = pd.read_csv('../data/c_rep_v_line_counter_v25.csv', header=None)

data5 = pd.read_csv('../data/a_rep_v_line_all_k_response_v20.csv', header=None)
data6 = pd.read_csv('../data/c_rep_v_line_all_k_response_v20.csv', header=None)
data7 = pd.read_csv('../data/a_rep_v_line_all_k_response_v25.csv', header=None)
data8 = pd.read_csv('../data/c_rep_v_line_all_k_response_v25.csv', header=None)

show_tracking = True
show_response = True

plt.figure()
k = range(10, 50, 3)
iterations = 100000

if show_tracking:
    plt.plot(k, data1.iloc[0]/iterations, label='$v = 20$', color='tab:blue')
    plt.plot(k, data2.iloc[0]/iterations, linestyle='dashed', color='tab:blue')
    plt.plot(k, data3.iloc[0]/iterations, label='$v = 25$', color='tab:red')
    plt.plot(k, data4.iloc[0]/iterations, linestyle='dashed', color='tab:red')

    plt.xlabel('$k$')
    plt.title('Tracking Performance')

    plt.ylabel('Percentage of Time on Target')
    plt.legend(loc='upper right', frameon=False)
    plt.show()

if show_response:
    plt.plot(k, data5.iloc[0], label='$v = 20$', color='tab:blue')
    plt.plot(k, data6.iloc[0], linestyle='dashed', color='tab:blue')
    plt.plot(k, data7.iloc[0], label='$v = 25$', color='tab:red')
    plt.plot(k, data8.iloc[0], linestyle='dashed', color='tab:red')

    plt.xlabel('$k$')
    plt.title('System Response')

    plt.ylabel('Cumulative Velocity Fluctuation Magnitude')
    plt.legend(loc='upper right', frameon=False)
    plt.show()

