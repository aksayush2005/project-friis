# OSM-Based RF Coverage and Network Planning Simulator

## Overview
This project is an interactive **RF (Radio Frequency)** network simulation tool developed in MATLAB. It integrates real-world geographic data from **OpenStreetMap (OSM)** with wireless communication models to simulate signal propagation, interference, and network coverage.

The system enables users to place base stations, configure antenna orientations, and evaluate network performance using **SINR (Signal-to-Interference-plus-Noise Ratio)**. It also provides intelligent recommendations for antenna angles when coverage is insufficient.

---

## Key Features
* **OSM Integration:** Uses `.osm` files for real-world urban environment modeling.
* **Obstacle Modeling:** Automatic extraction of building footprints as signal barriers.
* **Sectorized Antennas:** Directional antenna modeling with configurable orientation.
* **Realistic Propagation:** Includes path loss, log-normal shadowing, and reflection.
* **Interactive GUI:** Tools for base station placement and parameter configuration.
* **Coverage Optimization:** Recommendation system to improve antenna angles.
* **Visual Analytics:** Heatmaps, contour plots, and 3D signal surfaces.

---

## Mathematical Modeling

### 1. Path Loss Model
The received power is calculated using a distance-based path loss model:

$$P_r = \frac{P_t \cdot G_t \cdot G_r}{d^n}$$

**Where:**
* $P_r$: Received power
* $P_t$: Transmit power
* $G_t, G_r$: Transmitter and receiver gains
* $d$: Distance between transmitter and receiver
* $n$: Path loss exponent

### 2. Directional Antenna Model
The angle between transmitter and receiver:

$$\theta = \tan^{-1}\left(\frac{y - y_t}{x - x_t}\right)$$

Relative angle with antenna orientation ($\theta_0$):

$$\theta_{rel} = \theta - \theta_0$$

Directional gain is modeled using a Gaussian beam pattern:

$$G(\theta) = e^{-\frac{\theta_{rel}^2}{2\sigma^2}}$$

### 3. Shadowing (Log-Normal Fading)
$$P_{r\_shadowed} = P_r \cdot 10^{\frac{\sigma X}{10}}$$

**Where:**
* $\sigma$: Standard deviation
* $X$: Gaussian random variable ($X \sim \mathcal{N}(0,1)$)

### 4. Reflection (Multipath Approximation)
$$P_{total} = P_{direct} + \alpha \cdot P_{reflected}$$

**Where:**
* $\alpha$: Reflection coefficient

### 5. SINR Calculation
The Signal-to-Interference-plus-Noise Ratio is calculated as:

$$SINR = \frac{S}{I + N}$$

**Where:**
* $S$: Useful signal power
* $I$: Interference from neighboring transmitters
* $N$: Thermal noise power

### 6. Coverage Metric
$$Coverage = \frac{\text{Points where } (SINR > \text{threshold})}{\text{Total Grid Points}}$$

---

## System Workflow
1.  **Parsing:** Extract building coordinates and metadata from the OSM file.
2.  **Grid Generation:** Create a simulation area based on geographic bounds.
3.  **Deployment:** Place towers and set initial sector angles via GUI.
4.  **Simulation:** Run propagation models taking obstacles into account.
5.  **Evaluation:** Generate SINR maps and calculate total coverage.
6.  **Optimization:** Use the recommendation engine to refine antenna tilt/azimuth.

---

## Technologies Used
* **MATLAB:** Primary environment for simulation and GUI.
* **OpenStreetMap (OSM):** Source for geospatial data.
* **Signal Processing Toolbox:** For RF modeling and analysis.

---

## Future Improvements
* Integration of **Ray Tracing** for precise multipath modeling.
* **Machine Learning** algorithms for automated tower placement.
* Support for **Dynamic Mobility** (moving users/receivers).
