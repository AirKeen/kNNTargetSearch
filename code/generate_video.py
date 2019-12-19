import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import animation

iterations = 500
agents = 50
detection_range = 1

target_data = pd.read_csv('./data/a_rep_target_positions.csv', header=None)
agent_data = pd.read_csv('./data/a_rep_agent_positions.csv', header=None)
# velocity_data = pd.read_csv('data/agents_velocities.csv', header=None)

target_positions = []
agent_position_history = []
velocity_history = []

show_vel_lines = False

show_ani = True
save_ani = False

if show_ani or save_ani:
    for iter in range(iterations):
        current_positions = []
        current_velocities = []
        for agent in range(agents):
            agent_pos = agent_data[iter][agent]
            agent_pos = agent_pos.replace('[', '').replace(']', '').split(',')
            # velocity = velocity_data[iter][agent]
            # velocity = velocity.replace('[', '').replace(']', '').split(',')
            for i in range(len(agent_pos)):
                agent_pos[i] = float(agent_pos[i])
                # velocity[i] = float(velocity[i])
            current_positions.append(agent_pos)
            # current_velocities.append(velocity)
        agent_position_history.append(current_positions)
        # velocity_history.append(current_velocities)

    x = np.linspace(-10, 10, 200)
    y = np.linspace(-10, 10, 200)
    X, Y = np.meshgrid(x, y)
    target_field = []

    for i in range(iterations):
        current_position = [target_data[i][0], target_data[i][1]]
        target_positions.append(current_position)

        instantaneous_field = np.zeros([200, 200])
        for ix in range(200):
            for iy in range(200):
                if ((X[iy][ix] - current_position[0]) ** 2 + (Y[iy][ix] - current_position[1]) ** 2) <= detection_range ** 2:
                    instantaneous_field[iy][ix] = -10
                else:
                    instantaneous_field[iy][ix] = 0
        print(i)
        target_field.append(instantaneous_field)

    fig = plt.figure(figsize=[6, 6])
    ax = plt.axes(xlim=(-10, 10), ylim=(-10, 10))
    counter = fig.text(0.8, 0.035, '', transform=plt.gcf().transFigure)

    points, = ax.plot([], [], 'kx')
    f_points, = ax.plot([], [], 'bx')
    if show_vel_lines:
        vel_lines = []
        for i in range(agents):
            vel_line, = ax.plot([], [], color='b', lw=1, ls='dashed', alpha=.7)
            vel_lines.append(vel_line)

    xdata, ydata, xvdata, yvdata = [], [], [], []

    for i in range(iterations):
        X_pos, Y_pos = [], []
        for position in agent_position_history[i]:
            X_pos.append(position[0])
            Y_pos.append(position[1])
        xdata.append(X_pos[0:(agents-1)])
        ydata.append(Y_pos[0:(agents-1)])

        if show_vel_lines:
            X_vel, Y_vel = [], []
            for velocity in velocity_history[i]:
                X_vel.append(velocity[0])
                Y_vel.append(velocity[1])
            xvdata.append(X_vel)
            yvdata.append(Y_vel)


def init():
    points.set_data([], [])
    f_points.set_data([], [])
    if show_vel_lines:
        vel_line.set_data([], [])
        return points, vel_lines,
    else:
        return points,


def animate(i):
    ax.contourf(X, Y, target_field[i])
    counter.set_text('Iteration %01d' % i)
    x = xdata[i]
    y = ydata[i]
    points.set_data(x, y)

    if show_vel_lines:
        for n in range(agents):
            vel_lines[n].set_data([x[n] + xvdata[i][n], x[n]], [y[n] + yvdata[i][n], y[n]])
        return counter, points, vel_lines,
    else:
        return counter, points,


if show_ani or save_ani:
    anim = animation.FuncAnimation(fig, animate, init_func=init, frames=iterations)
if show_ani:
    plt.show()
if save_ani:
    anim.save('./video.mp4', writer='ffmpeg', fps=30)