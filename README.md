
# k-Nearest Neighbours Target Search

This repo contains the code for simulating and performing analysis of a swarm of decentralised agents tracking a target in random motion around a search space. The code used to run the simulation and perform data analysis can be found in `code` and the data used for generating the plots and videos can be found in `data`.

## Citation Information

If you would like to use this code in your research, please use this citation:
Hian Lee Kwa, Jabez Leong Kit, Roland Bouffanais. 2020. Optimal Swarm Strategy for Dynamic Target Search and Tracking. In Proc. of the 19th International Conference on Autonomous Agents and Multiagent Systems (AAMAS2020), Auckland, New Zealand, May 9–13, 2020, IFAAMAS, 9 pages.

## Usage
### Dependencies
The code for the simulation is written using Julia 1.1 (Click [here](https://julialang.org/) to install), while the codes for data analysis are written using Python 3.6. The following Python packages need to be installed to run the codes properly:

- NumPy
- Matplotlib
- Pandas
- PyLaTeX

### Codes
|Code Name| Description|
|---------|------------|
|perpetual_motion.jl| Code for running simulation.|
|generate_video.py| Creates a video of a simulations.|
|target_speed_analysis.py| For a fixed *k*-value, shows swarm performance for different target velocities.|
|k_analysis.py| For a fixed target velocity, shows swarm performance for different *k*-values.|
|heading_bearing_correlation.py| Generates historams to show the heading-bearing correlation of the swarm in different conditions.|
