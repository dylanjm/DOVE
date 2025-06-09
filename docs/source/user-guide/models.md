# Models

## Price Taker Model in DOVE: Mathematical Formulation

### Overview

The Price Taker model in DOVE represents a market participant that accepts energy market prices as given and optimizes operations accordingly. This document provides the complete mathematical formulation of the model, explaining all variables, constraints, and the objective function.

### Sets and Indices

| Symbol | Description |
|--------|-------------|
| $\mathcal{C}$ | Set of all components |
| $\mathcal{C}_N$ | Set of non-storage components |
| $\mathcal{C}_S$ | Set of storage components |
| $\mathcal{R}$ | Set of resources |
| $\mathcal{T}$ | Set of time periods |
| $c$ | Index for components |
| $r$ | Index for resources |
| $t$ | Index for time periods |

### Variables

| Variable | Domain | Description |
|----------|--------|-------------|
| $\text{flow}_{c,r,t}$ | $\mathbb{R}^+$ | Resource flow for component $c$ of resource $r$ at time $t$ |
| $\text{SOC}_{c,t}$ | $\mathbb{R}^+$ | State of charge for storage component $c$ at time $t$ |
| $\text{charge}_{c,t}$ | $\mathbb{R}^+$ | Charging activity for storage component $c$ at time $t$ |
| $\text{discharge}_{c,t}$ | $\mathbb{R}^+$ | Discharging activity for storage component $c$ at time $t$ |
| $\text{ramp\_up}_{c,t}$ | $\mathbb{R}^+$ | Upward ramping magnitude for component $c$ at time $t$ |
| $\text{ramp\_down}_{c,t}$ | $\mathbb{R}^+$ | Downward ramping magnitude for component $c$ at time $t$ |
| $\text{ramp\_up\_bin}_{c,t}$ | $\{0,1\}$ | Binary indicator for upward ramping of component $c$ at time $t$ |
| $\text{ramp\_down\_bin}_{c,t}$ | $\{0,1\}$ | Binary indicator for downward ramping of component $c$ at time $t$ |
| $\text{steady\_bin}_{c,t}$ | $\{0,1\}$ | Binary indicator for steady state operation of component $c$ at time $t$ |

### Parameters

| Parameter | Description |
|-----------|-------------|
| $\text{max\_capacity}_c$ | Maximum capacity of component $c$ |
| $\text{min\_capacity}_c$ | Minimum capacity of component $c$ |
| $\text{profile}_{c,t}$ | Time-varying profile for component $c$ at time $t$ |
| $\text{ramp\_limit}_c$ | Maximum fractional change in output between time periods for component $c$ |
| $\text{ramp\_freq}_c$ | Minimum time periods between ramping events for component $c$ |
| $\text{rte}_c$ | Round-trip efficiency of storage component $c$ |
| $\text{max\_charge\_rate}_c$ | Maximum charging rate (fraction of capacity) for storage component $c$ |
| $\text{max\_discharge\_rate}_c$ | Maximum discharging rate (fraction of capacity) for storage component $c$ |
| $\text{initial\_stored}_c$ | Initial stored energy (fraction of capacity) for storage component $c$ |
| $\text{price\_profile}_{cf,t}$ | Time-varying price profile for cashflow $cf$ at time $t$ |
| $\text{sign}_{cf}$ | Sign of cashflow $cf$ (positive for revenue, negative for cost) |
| $\text{dprime}_{cf}$ | Reference capacity for cashflow $cf$ used in scaling |
| $\text{scalex}_{cf}$ | Exponent for non-linear cashflow scaling |

### Constraints

#### 1. Component Transfer Constraints

For all converter components, the transfer function relates input flows to output flows:

$$\text{transfer\_fn}_c(\{\text{flow}_{c,r,t} : r \in \text{consumes}_c\}, \{\text{flow}_{c,r,t} : r \in \text{produces}_c\}) = 0, \quad \forall c \in \mathcal{C}_N, t \in \mathcal{T}$$

Where $\text{transfer\_fn}_c$ is a component-specific function such as:
- **Ratio Transfer**: $\text{flow}_{c,r_{\text{out}},t} = \alpha \cdot \text{flow}_{c,r_{\text{in}},t}$
- **Polynomial Transfer**: More complex relationships defined by polynomial coefficients

#### 2. Capacity Constraints

Upper and lower bounds on component capacity:

$$\text{flow}_{c,r_c,t} \leq \text{max\_capacity}_c, \quad \forall c \in \mathcal{C}_N, t \in \mathcal{T}$$

$$\text{flow}_{c,r_c,t} \geq \text{min\_capacity}_c, \quad \forall c \in \mathcal{C}_N, t \in \mathcal{T}$$

Where $r_c$ is the capacity resource for component $c$.

#### 3. Fixed Profile Constraints

For components with fixed profiles:

$$\text{flow}_{c,r_c,t} = \text{profile}_{c,t}, \quad \forall c \in \mathcal{C}_N \text{ with fixed profiles}, t \in \mathcal{T}$$

#### 4. Resource Balance Constraints

For each resource and time period, production must equal consumption:

$$\sum_{c \in \mathcal{C}_N: r \in \text{produces}_c} \text{flow}_{c,r,t} + \sum_{c \in \mathcal{C}_S: \text{resource}_c = r} \text{discharge}_{c,t} = \sum_{c \in \mathcal{C}_N: r \in \text{consumes}_c} \text{flow}_{c,r,t} + \sum_{c \in \mathcal{C}_S: \text{resource}_c = r} \text{charge}_{c,t}, \quad \forall r \in \mathcal{R}, t \in \mathcal{T}$$

#### 5. Storage Constraints

##### State of Charge Balance

$$\text{SOC}_{c,t} = \begin{cases}
\text{initial\_stored}_c \cdot \text{max\_capacity}_c + \text{charge}_{c,t} \cdot \sqrt{\text{rte}_c} - \frac{\text{discharge}_{c,t}}{\sqrt{\text{rte}_c}}, & \text{if } t = \text{first}(T) \\
\text{SOC}_{c,t-1} + \text{charge}_{c,t} \cdot \sqrt{\text{rte}_c} - \frac{\text{discharge}_{c,t}}{\sqrt{\text{rte}_c}}, & \text{otherwise}
\end{cases}, \quad \forall c \in \mathcal{C}_S, t \in \mathcal{T}$$

##### Charging and Discharging Limits

$$\text{charge}_{c,t} \leq \text{max\_charge\_rate}_c \cdot \text{max\_capacity}_c, \quad \forall c \in \mathcal{C}_S, t \in \mathcal{T}$$

$$\text{discharge}_{c,t} \leq \text{max\_discharge\_rate}_c \cdot \text{max\_capacity}_c, \quad \forall c \in \mathcal{C}_S, t \in \mathcal{T}$$

##### State of Charge Limits

$$\text{SOC}_{c,t} \leq \text{max\_capacity}_c, \quad \forall c \in \mathcal{C}_S, t \in \mathcal{T}$$

#### 6. Ramping Constraints

##### Ramping Rate Limits

$$\text{flow}_{c,r_c,t} - \text{flow}_{c,r_c,t-1} \leq \text{ramp\_limit}_c \cdot \text{max\_capacity}_c, \quad \forall c \in \mathcal{C}_N \text{ with ramp limits}, t > 1$$

$$\text{flow}_{c,r_c,t-1} - \text{flow}_{c,r_c,t} \leq \text{ramp\_limit}_c \cdot \text{max\_capacity}_c, \quad \forall c \in \mathcal{C}_N \text{ with ramp limits}, t > 1$$

##### Ramping Tracking

$$\text{ramp\_up}_{c,t} \geq \text{flow}_{c,r_c,t} - \text{flow}_{c,r_c,t-1}, \quad \forall c \in \mathcal{C}_N \text{ with ramp frequency}, t > 1$$

$$\text{ramp\_down}_{c,t} \geq \text{flow}_{c,r_c,t-1} - \text{flow}_{c,r_c,t}, \quad \forall c \in \mathcal{C}_N \text{ with ramp frequency}, t > 1$$

##### Binary Ramping Indicators

$$\text{ramp\_up}_{c,t} \leq \text{max\_capacity}_c \cdot \text{ramp\_up\_bin}_{c,t}, \quad \forall c \in \mathcal{C}_N \text{ with ramp frequency}, t > 1$$

$$\text{ramp\_down}_{c,t} \leq \text{max\_capacity}_c \cdot \text{ramp\_down\_bin}_{c,t}, \quad \forall c \in \mathcal{C}_N \text{ with ramp frequency}, t > 1$$

##### Steady State Definition

$$\text{ramp\_up}_{c,t} \leq M \cdot (1 - \text{steady\_bin}_{c,t}), \quad \forall c \in \mathcal{C}_N \text{ with ramp frequency}, t > 1$$

$$\text{ramp\_down}_{c,t} \leq M \cdot (1 - \text{steady\_bin}_{c,t}), \quad \forall c \in \mathcal{C}_N \text{ with ramp frequency}, t > 1$$

Where $M = 2 \cdot \text{max\_capacity}_c$ is a sufficiently large constant.

##### State Selection

$$\text{ramp\_up\_bin}_{c,t} + \text{ramp\_down\_bin}_{c,t} + \text{steady\_bin}_{c,t} = 1, \quad \forall c \in \mathcal{C}_N \text{ with ramp frequency}, t \in \mathcal{T}$$

##### Ramping Frequency Limitation

$$\sum_{t' \in \mathcal{T}: t-\text{ramp\_freq}_c < t' \leq t} (\text{ramp\_up\_bin}_{c,t'} + \text{ramp\_down\_bin}_{c,t'}) \leq 1, \quad \forall c \in \mathcal{C}_N \text{ with ramp frequency}, t \in \mathcal{T}$$

### Objective Function

The objective is to maximize total economic value:

$$\text{Maximize} \sum_{c \in \mathcal{C}} \sum_{cf \in \text{cashflows}_c} \sum_{t \in \mathcal{T}} \text{sign}_{cf} \cdot \text{price\_profile}_{cf,t} \cdot \left(\frac{\text{dispatch}_{c,t}}{\text{dprime}_{cf}}\right)^{\text{scalex}_{cf}}$$

Where $\text{dispatch}_{c,t}$ is:
- $\text{flow}_{c,r_c,t}$ for non-storage components
- $\text{SOC}_{c,t}$ for storage components

### Model Features and Applications

#### Key Features

1. **Flexible Resource Handling**: Models any number of resources flowing between components
2. **Storage Representation**: Accurately captures energy storage dynamics including efficiency losses
3. **Ramping Constraints**: Models both rate limitations and frequency restrictions on output changes
4. **Non-linear Cashflows**: Supports non-linear economic valuation through scaling parameters
5. **Time-varying Profiles**: Handles time-dependent capacity factors, prices, and demand profiles

#### Applications

The Price Taker model is suitable for:

- **Market Participation Analysis**: Optimize bidding strategies in energy markets
- **Hybrid System Planning**: Design integrated renewable and conventional generation systems
- **Storage Valuation**: Assess the economic value of energy storage under different market conditions
- **Flexibility Studies**: Evaluate the impact of operational constraints on system economics
- **Demand Response**: Model load shifting and other demand-side management strategies

### Simplifications and Assumptions

1. Transmission constraints are not explicitly modeled
2. All components are assumed to be continuously dispatchable within their limits
3. Binary on/off decisions are not modeled (except for ramping state tracking)
4. Perfect foresight of prices and profiles over the optimization horizon
5. No stochasticity or uncertainty consideration in the base formulation

### Using the Model in DOVE

```python
# Example: Creating and solving a price taker model
import dove

# Create system components
generator = dove.Source(name="generator", produces=electricity, max_capacity=100)
battery = dove.Storage(name="battery", resource=electricity, max_capacity=50, rte=0.9)
load = dove.Sink(name="load", consumes=electricity, profile=demand_profile)

# Add ramping constraints to generator
generator.ramp_limit = 0.2  # 20% per time step
generator.ramp_freq = 4     # One ramp event per 4 time steps

# Create and solve the system
system = dove.System(time_index=hours)
system.add_component(generator)
system.add_component(battery)
system.add_component(load)

# Solve as price taker
results = system.solve(model_type="price_taker")
```
