using Distributions, Distances, Parameters, PyCall, PyPlot, LinearAlgebra, Random, Statistics
using DelimitedFiles,  CSV, DataFrames
np = pyimport("numpy")

# PSO Settings
w = 0.5
chi = 1.
c1 = 0.
c2 = 0.5
max100 = 10
max_speed = max100 / 100
iter_max = 1000
n_particles = 50
n_neighbours = 10 #range(10, stop=49, step=3)

# Default Repulsion Settings
repulsion = true
var_repulsion = true
d_def = 6
rep_radius_def = 2

# Target Settings
target_speed = [20] # range(10, stop=14, step=2)
move_per_it = target_speed / 100
detection_radius = 1
turn_limit = 20

function fitness(target_loc::Vector, position::Vector, radius::Int)
    X = position[1]
    Y = position[2]
    target_x = target_loc[1]
    target_y = target_loc[2]
    radius = radius
    if ((X - target_x)^2 + (Y - target_y)^2) <= radius ^ 2
        fit = -1
    else
        fit = 0
    end
    return fit
end

@with_kw mutable struct Particle
    name::String
    nearest_neighbours::Int
    max_speed::Float64

    position::Vector = [rand(Uniform(-10, 10)), rand(Uniform(-10, 10))]
    velocity::Vector = [0, 0]
    heading::Float64 = 90.0
    fit::Float64 = Inf
    waypoint::Vector = position

    repulsion::Bool
    d::Float64
    rep_radius::Float64
    repulsion_neighbours::Int

    pbest_pos = position
    pbest_value = fit
    nbest_pos = []
    nbest_value = Inf
    neighbour_name = name
    explore = false
    track = true

    rep_vector = [0, 0]
    pso_vector = [0, 0]
    heading_vector = [0, 0]
end

function get_neighbours(self::Particle, pList::Array, k::Int)
    neighbour_number = 0
    neighbour_pos = []
    neighbour_vals = []
    neighbour_dist = []
    neighbour_names = []
    for p in pList
        if self.name == p.name
            continue
        elseif neighbour_number < k
            neighbour_number += 1
            distance = abs(euclidean(self.position, p.position))
            push!(neighbour_pos, p.position)
            push!(neighbour_vals, p.fit)
            push!(neighbour_dist, distance)
            push!(neighbour_names, p.name)
        elseif neighbour_number >= k
            distance = abs(euclidean(self.position, p.position))
            if distance < maximum(neighbour_dist)
                index = argmax(neighbour_dist)
                deleteat!(neighbour_dist, index)
                push!(neighbour_dist, distance)
                deleteat!(neighbour_pos, index)
                push!(neighbour_pos, p.position)
                deleteat!(neighbour_vals, index)
                push!(neighbour_vals, p.fit)
                deleteat!(neighbour_names, index)
                push!(neighbour_names, p.name)
            end
        end
    end
    return neighbour_pos, neighbour_vals, neighbour_names
end

function get_repulsion_neighbours(self::Particle, pList::Array, rep_neighbours::Int)
    neighbour_number = 0
    neighbour_pos = []
    neighbour_dist = []
    for p in pList
        if self.name == p.name
            continue
        elseif neighbour_number < rep_neighbours
            neighbour_number += 1
            distance = abs(euclidean(self.position, p.position))
            push!(neighbour_pos, p.position)
            push!(neighbour_dist, distance)
        elseif neighbour_number >= rep_neighbours
            distance = abs(euclidean(self.position, p.position))
            if distance < maximum(neighbour_dist)
                index = argmax(neighbour_dist)
                deleteat!(neighbour_dist, index)
                push!(neighbour_dist, distance)
                deleteat!(neighbour_pos, index)
                push!(neighbour_pos, p.position)
            end
        end
    end

    return neighbour_pos
end

function set_nbest(self::Particle, positions::Array, values::Array, neighbour_names::Array)
    self.nbest_value = minimum(values)
    index = argmin(values)
    self.nbest_pos = positions[index]
    self.neighbour_name = neighbour_names[index]
    # If agent and neighbours are not on target, explore. Else, perform tracking
    if self.fit == 0 && self.nbest_value == 0
        self.explore = true
        self.track = false
    elseif self.fit < 0 || self.nbest_value < 0
        self.explore = false
        self.track = true
    end
    if self.fit <= self.nbest_value
        self.nbest_pos = self.position
        self.nbest_value = self.fit
        self.neighbour_name = self.name
    end
end

function set_pso_velocity(self::Particle)
    global w, c1, c2, chi
    self.velocity = chi * ((w .* self.velocity)
                    + (c1 * rand(1) .* (self.pbest_pos - self.position))
                    + (c2 * rand(1) .* (self.nbest_pos - self.position)))
    self.pso_vector = self.velocity / norm(self.velocity)
end

function set_repulsion_velocity(self::Particle, neighbour_positions::Array)
    # Repulsion parameters
    global n_particles, var_repulsion
    self.rep_vector = [0, 0]
    if var_repulsion
        if self.explore == true && self.rep_radius < 6
            # If agent set to explore, increment repulsion radius by 0.5
            self.rep_radius += 0.1
        elseif self.track == true && self.rep_radius > 1.5
            self.rep_radius -= 0.2
        end
    else
        self.rep_radius = 2
    end
    S = pi * self.rep_radius^2
    alpha_r = sqrt(S / n_particles)
    rep_vel = [0, 0]

    for p in neighbour_positions
        vector = self.position - p
        dist = euclidean(self.position, p)
        self.velocity += ((alpha_r / dist) ^ self.d) * (vector / dist)
        self.rep_vector += ((alpha_r / dist) ^ self.d) * (vector / dist)
    end
    self.rep_vector /= norm(self.rep_vector)
end

function update_waypoint(self::Particle)

    speed = norm(self.velocity)

    # Limit particle speed to maximum speed
    if norm(self.velocity) > self.max_speed
        self.velocity = (self.max_speed / speed) * self.velocity
        speed = norm(self.velocity)
    end

    angle = atand(self.velocity[2], self.velocity[1])
    heading = angle

    if heading < 0
        heading += 360
    elseif heading >= 360
        heading -= 360
    end
    self.velocity[1] = speed * cosd(heading)
    self.velocity[2] = speed * sind(heading)
    self.waypoint = self.position + self.velocity
    self.heading_vector = [cosd(heading), sind(heading)]

    # Boundary conditions
    if abs(self.waypoint[1]) > 8.5 || abs(self.waypoint[2]) > 8.5
        if self.waypoint[1] > 8.5
            self.waypoint[1] = 8.5
        elseif self.waypoint[1] < -8.5
            self.waypoint[1] = -8.5
        end
        if self.waypoint[2] > 8.5
            self.waypoint[2] = 8.5
        elseif self.waypoint[2] < -8.5
            self.waypoint[2] = -8.5
        end
        self.velocity = self.waypoint - self.position
    end

    self.position = self.waypoint
end

function reset_values(target_loc::Array, self::Particle, radius::Int)
    """
    Resets nbest positions and values after each iteration.
    """

    self.pbest_value = Inf
    self.fit = fitness(target_loc, self.position, radius)
    self.nbest_value = Inf
    self.nbest_pos = self.position
end

all_response = []
all_phi_bins_11 = []
all_counters = []
for v in target_speed
    start = time_ns()
    Random.seed!(94123)
    global all_response, detection_radius, turn_limit, sum_mag,
    sum_pso, sum_rep, target_current, target_history, target_velocity

    k = n_neighbours
    repulsion_neighbours = k
    move_per_it = v/100

    particle_list = []
    pos_current = []
    pos_history = []
    vel_current = []
    vel_history = []
    target_current = []
    target_history = []
    target_velocity = []
    sum_mag = []
    phi_bins_11 = zeros(11)
    counter = 0

    # Initialise particles
    for i in range(1, stop=n_particles)
        name = "Particle " * string(i)
        particle = Particle(name=name, nearest_neighbours=k,
                            max_speed=max_speed, repulsion=repulsion, d=d_def,
                            rep_radius=rep_radius_def,
                            repulsion_neighbours=repulsion_neighbours)
        push!(particle_list, particle)

    end

    # Initialise target
    target_current = [rand(Uniform(-8, 8)), rand(Uniform(-8, 8))]
    target_velocity = [0.15, 0]
    target_wp = [rand(Uniform(-8, 8)), rand(Uniform(-8, 8))]
    target_timer = 0

    iteration = 0
    while iteration < iter_max
        pos_current = []
        vel_current = []

        # First update particle fitness values for all particles
        for particle in particle_list
            global radius
            push!(pos_current, particle.position)
            push!(vel_current, particle.velocity)
            particle.fit = fitness(target_current, particle.position, detection_radius)
        end

        push!(pos_history, pos_current)

        # Update nbest and calculate PSO velocity
        for particle in particle_list
            positions, n_values, neighbour_names = get_neighbours(particle, particle_list, k)
            set_nbest(particle, positions, n_values, neighbour_names)
            set_pso_velocity(particle)
            if repulsion
                rep_neighbour_pos = get_repulsion_neighbours(particle, particle_list,
                                                            repulsion_neighbours)
                set_repulsion_velocity(particle, positions)
            end

            update_waypoint(particle)

        end

        for particle in particle_list
            vec_to_target = target_current - particle.position
            bearing = vec_to_target / norm(vec_to_target)

            # If particle is travelling at less than 10% of max speed, consider stationary
            if norm(particle.velocity) < 0.01
                phi_bins_11[6] += 1
            else
                c_phi = dot(bearing, particle.heading_vector)
                # This whole lot is for separating into bins.
                if c_phi >= 0.9
                    phi_bins_11[1] += 1
                elseif 0.7 <= c_phi < 0.9
                    phi_bins_11[2] += 1
                elseif 0.5 <= c_phi < 0.7
                    phi_bins_11[3] += 1
                elseif 0.3 <= c_phi < 0.5
                    phi_bins_11[4] += 1
                elseif 0.1 <= c_phi < 0.3
                    phi_bins_11[5] += 1
                elseif -0.1 <= c_phi < 0.1
                    phi_bins_11[6] += 1
                elseif -0.3 <= c_phi < -0.1
                    phi_bins_11[7] += 1
                elseif -0.5 <= c_phi < -0.3
                    phi_bins_11[8] += 1
                elseif -0.7 <= c_phi < -0.5
                    phi_bins_11[9] += 1
                elseif -0.9 <= c_phi < -0.7
                    phi_bins_11[10] += 1
                elseif c_phi < -0.9
                    phi_bins_11[11] += 1
                end
            end
        end
        for particle in particle_list
            if particle.fit < 0
                counter += 1
                break
            end
        end

        flux_current = []
        mean_velocity = mean(vel_current)
        for velocity in vel_current
            flux = norm(mean_velocity - velocity)
            push!(flux_current, flux)
        end
        push!(sum_mag, [sum(flux_current)])
        push!(target_history, target_current)

        # Update target position
        dist_to_wp = abs(euclidean(target_current, target_wp))
        if dist_to_wp <= 1.5  || target_timer >= 200
            target_wp = [rand(Uniform(-8, 8)), rand(Uniform(-8, 8))]
            target_timer = 0
        end
        target_timer += 1
        req_heading = atand((target_wp[2] - target_current[2]),
                            (target_wp[1] - target_current[1]))
        current_heading = atand(target_velocity[2], target_velocity[1])
        angle_diff = req_heading - current_heading
        if angle_diff > 180
            angle_diff -= 360
        elseif angle_diff < -180
            angle_diff += 360
        end

        if abs(angle_diff) > turn_limit
            if angle_diff > 0
                current_heading += turn_limit
            else
                current_heading -= turn_limit
            end
        else
            current_heading = req_heading
        end

        target_velocity = [cosd(current_heading), sind(current_heading)] * move_per_it
        target_current = [(target_current[1] + target_velocity[1]),
                            (target_current[2] + target_velocity[2])]

        println("K = ", k, " V = ", string(v), " Iteration: ", iteration)
        iteration += 1
    end
    phi_bins_11 = phi_bins_11/iter_max
    push!(all_phi_bins_11, phi_bins_11)
    push!(all_counters, [counter])

    file_name1 = "target_positions.csv"
    file_name2 = "agent_positions.csv"
    # file_name3 = "agent_velocities.csv"

    CSV.write(file_name1, DataFrame(target_history), writeheader=false)
    CSV.write(file_name2, DataFrame(pos_history), writeheader=false)
    # CSV.write(file_name3, DataFrame(vel_history), writeheader=false)

    response = mean(sum_mag)
    push!(all_response, response)
    text = "Averaged response for K = " * string(k) * " , V = " * string(v) * ": " * string(response)
    println(text)
    text = "Tracking Counter K" * string(k) * " V" * string(v) * ": " * string(counter)
    println(text)
    finish = time_ns()
    time_taken = (finish - start) / (1e9 * 60)
    println("Time taken: ", string(time_taken), " mins")
end

# phi_11bins_file = "c_rep_phi_11bins_v" * string(n_neighbours) * ".csv"
# all_response_file = "c_rep_extended_all_k_response_k" * string(n_neighbours) * ".csv"
# counter_file = "c_rep_extended_counter_k" * string(n_neighbours) * ".csv"
#
# CSV.write(phi_11bins_file, DataFrame(all_phi_bins_11), writeheader=false)
# CSV.write(all_response_file, DataFrame(all_response), writeheader=false)
# CSV.write(counter_file, DataFrame(all_counters), writeheader=false)
