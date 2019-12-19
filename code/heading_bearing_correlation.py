import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import pylatex as ptx

plt.rcParams.update({'font.size': 14})
fig, axs = plt.subplots(3, 2, figsize=[6, 8])
plt.setp(axs, ylim=[0, 35])
plt.subplots_adjust(top=0.92, bottom=0.05)

p1 = '../data/a_rep_phi_11bins_k20.csv'
p2 = '../data/a_rep_phi_11bins_k49.csv'
p3 = '../data/c_rep_phi_11bins_k20.csv'
p4 = '../data/c_rep_phi_11bins_k49.csv'

data1 = pd.read_csv(p1, header=None)
data1 = data1.iloc[::-1]
data2 = pd.read_csv(p2, header=None)
data2 = data2.iloc[::-1]
data3 = pd.read_csv(p3, header=None)
data3 = data3.iloc[::-1]
data4 = pd.read_csv(p4, header=None)
data4 = data4.iloc[::-1]

bin_centres = np.linspace(-1, 1, 11)

# For this example, the columns are for target velocities = [10, 15, 20, 25, 30, 35, 40, 45, 50]
weights1 = data1[1]
weights2 = data2[1]
weights3 = data1[7]
weights4 = data2[7]
weights5 = data3[7]
weights6 = data3[7]

axs[0, 0].hist(bin_centres, bins=11, weights=weights1, color='tab:blue')
plt.text(-2.65, 112, '$k = 20$, $v = 15$ \n Adaptive Repulsion', horizontalalignment='center', fontsize=12)
axs[0, 1].hist(bin_centres, bins=11, weights=weights2, color='tab:blue')
plt.text(0.02, 112, '$k = 49$, $v = 15$ \n Adaptive Repulsion', horizontalalignment='center', fontsize=12)
axs[1, 0].hist(bin_centres, bins=11, weights=weights3, color='tab:blue')
plt.text(-2.65, 70, '$k = 20$, $v = 45$ \n Adaptive Repulsion', horizontalalignment='center', fontsize=12)
axs[1, 1].hist(bin_centres, bins=11, weights=weights4, color='tab:blue')
plt.text(0.02, 70, '$k = 49$, $v = 45$ \n Adaptive Repulsion', horizontalalignment='center', fontsize=12)
axs[2, 0].hist(bin_centres, bins=11, weights=weights5, color='tab:blue')
plt.text(-2.56, 28, '$k = 20$, $v = 45$ \n Constant Repulsion', horizontalalignment='center', fontsize=12)
axs[2, 1].hist(bin_centres, bins=11, weights=weights5, color='tab:blue')
plt.text(0.02, 28, '$k = 49$, $v = 45$ \n Constant Repulsion', horizontalalignment='center', fontsize=12)
axs[2, 0].set_xlabel('$\phi_i[t]$')
axs[2, 1].set_xlabel('$\phi_i[t]$')
plt.show()
