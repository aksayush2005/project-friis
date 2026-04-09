# OSM-Based RF Coverage and Network Planning Simulator

## Overview

This project is an interactive RF (Radio Frequency) network simulation tool developed in MATLAB. It integrates real-world geographic data from OpenStreetMap (OSM) with wireless communication models to simulate signal propagation, interference, and network coverage.

The system enables users to place base stations, configure antenna orientations, and evaluate network performance using SINR (Signal-to-Interference-plus-Noise Ratio). It also provides intelligent recommendations for antenna angles when coverage is insufficient.

This project demonstrates a combination of wireless communication theory, signal processing, and geospatial data analysis.

---

## Key Features

* Integration with OpenStreetMap (.osm) for real-world environments
* Automatic extraction of building footprints and conversion into obstacles
* Sectorized directional antenna modeling with configurable orientation
* Realistic RF propagation including path loss, shadowing, and reflection
* SINR-based performance evaluation
* Interactive GUI for tower placement and configuration
* Coverage percentage calculation
* Recommendation system for improving antenna angles
* Visualization through heatmaps, contour plots, and 3D surfaces

---

## System Architecture

The system follows a structured pipeline:

1. OSM data parsing
2. Building extraction and obstacle modeling
3. Grid generation
4. RF propagation simulation
5. SINR computation
6. Coverage evaluation
7. Visualization and recommendation

---

## Mathematical Modeling

### 1. Path Loss Model

The received power is calculated using a distance-based path loss model:

[
P_r = \frac{P_t \cdot G_t \cdot G_r}{d^n}
]

Where:

* (P_r) = Received power
* (P_t) = Transmit power
* (G_t, G_r) = Transmitter and receiver gains
* (d) = Distance between transmitter and receiver
* (n) = Path loss exponent

---

### 2. Directional Antenna Model

The angle between transmitter and receiver:

[
\theta = \tan^{-1}\left(\frac{y - y_t}{x - x_t}\right)
]

Relative angle with antenna orientation:

[
\theta_{rel} = \theta - \theta_0
]

Directional gain is modeled using a Gaussian beam pattern:

[
G(\theta) = e^{-\frac{\theta_{rel}^2}{2\sigma^2}}
]

---

### 3. Shadowing (Log-Normal Fading)

[
P_r = P_r \cdot 10^{\frac{\sigma X}{10}}
]

Where:

* (\sigma) = standard deviation
* (X) = Gaussian random variable

---

### 4. Reflection (Multipath Approximation)

[
P_{total} = P_{direct} + \alpha \cdot P_{reflected}
]

Where:

* (\alpha) = reflection coefficient

---

### 5. SINR Calculation

[
SINR = \frac{S}{I + N}
]

Where:

* (S) = signal power
* (I) = interference from other transmitters
* (N) = noise power

---

### 6. Coverage Metric

[
Coverage = \frac{\text{Number of points with } SINR > \text{threshold}}{\text{Total number of points}}
]

---

## Visualization Outputs

The system provides three types of visual outputs:

* Heatmap: Shows spatial variation of SINR
* Contour plot: Highlights coverage boundaries and interference regions
* 3D surface: Represents signal strength as a surface for better spatial understanding

---

## How It Works

1. Load an OpenStreetMap (.osm) file
2. The system extracts building data and creates obstacles
3. A simulation grid is generated
4. The user places base stations using the GUI
5. The user inputs antenna orientation angles
6. The system computes signal propagation and SINR
7. Coverage percentage is calculated
8. If coverage is low, the system suggests improved antenna angles
9. Results are visualized through multiple plots

---

## Applications

* Cellular network planning
* Antenna orientation optimization
* Coverage analysis in urban environments
* Detection of signal dead zones
* Educational tool for wireless communication concepts

---

## Limitations

* Uses simplified propagation models
* Building shapes are approximated as rectangles
* Does not include full ray tracing or diffraction modeling
* Assumes static environment (no mobility)

---

## Future Improvements

* Ray tracing for accurate multipath modeling
* Machine learning-based optimization of tower placement
* User density-based coverage planning
* Real-time interactive updates
* Integration with web-based mapping interfaces

---

## Technologies Used

* MATLAB
* OpenStreetMap (OSM data)
* Numerical simulation and visualization

---

## Conclusion

This project provides a practical and extensible framework for simulating wireless network behavior in real-world environments. It bridges theoretical RF modeling with interactive visualization, making it a valuable tool for both learning and applied network planning.

---
