# Smart Logistics Tracking System

A blockchain-powered logistics tracking system developed for the Applications Development and Emerging Technologies class (MO-IT148). This repository currently contains the IoT data simulation for Milestone 1, which generates raw sensor data for a smart tracking system focused on package tracking, supply chain transparency, and fraud prevention. It simulates 50 sensor readings across 10 shipments, exported as CSV for downstream processing.

## Features

- IoT sensor data simulation
  - GPS coordinate simulation for location tracking
  - RFID for package identity verification
  - Temperature for cold-chain monitoring
- Sensor readings log generation
- Shipment registry derived from RFID tags
- CSV export for downstream processing

## Tech Stack

- Python
- pandas, numpy, random
- Jupyter Notebook

## Project Structure

- `smart-logistics-iot-simulation.ipynb` – IoT data simulation notebook
- `sensor_readings.csv` – generated sensor log
- `shipment_registry.csv` – derived shipment metadata

## How to Run the Project

1. Clone the repository
   ```
   git clone <repository-url>
   ```

2. Go to the project folder
   ```
   cd smart-logistics-tracking
   ```

3. Create and activate a virtual environment

   **Windows**
   ```
   python -m venv venv
   venv\Scripts\activate
   ```

   **Mac/Linux**
   ```
   python3 -m venv venv
   source venv/bin/activate
   ```

4. Install dependencies
   ```
   pip install numpy pandas jupyter
   ```

5. Open the notebook
   ```
   jupyter notebook smart-logistics-iot-simulation.ipynb
   ```

6. Run the cells to generate the datasets

## Group Members

- Helena Rose Tantoco
- Chadley Marie De Lara
- Eugenio Villaverde
- Karissa Mae Manicad
- Martin Sheen Cajucom
- Rania Nabil Abdelfattah