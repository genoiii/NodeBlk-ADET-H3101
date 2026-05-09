# Smart Logistics IoT Tracking System — carGO PH

> MO-IT148 — Applications Development and Emerging Technologies <br>
> Section: H3101 <br>
> Group: NodeBlk <br>
> Last Updated: May 9, 2026

---

## Project Overview

A blockchain-powered logistics tracking system developed for the Applications Development and Emerging Technologies class (MO-IT148). This repository currently contains the IoT data simulation for Milestone 1, which generates raw sensor data for a smart tracking system focused on package tracking, supply chain transparency, and fraud prevention. It simulates GPS, RFID, and temperature sensor readings across 30 shipments, exported as CSV for downstream blockchain processing.

---

## Features

- IoT sensor data simulation
  - GPS coordinate tracking with real Philippine city coordinates and route interpolation
  - RFID checkpoint scanning with verified/flagged status
  - Temperature monitoring for cold-chain and temp-regulated goods
- Shipment registry with goods category, origin, destination, vehicle, and driver data
- Separate CSV exports per sensor type plus a unified IoT data feed
- CSV export for downstream blockchain processing

---

## Tech Stack

- Python
- pandas, numpy, random
- Jupyter Notebook

---

## Project Structure

- `smart-logistics-iot-simulation.ipynb` — IoT data simulation notebook
- `ph.csv` — Philippine city reference data (coordinates)
- `shipment_registry.csv` — shipment metadata (origin, destination, goods category, vehicle, driver)
- `gps_readings.csv` — GPS sensor readings per shipment
- `rfid_readings.csv` — RFID checkpoint scan readings
- `temperature_readings.csv` — temperature sensor readings (temp-regulated shipments only)
- `iot_data.csv` — unified IoT feed combining all sensor types, sorted by timestamp

---

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

---

## Weekly Progress

| Week | Milestone | Status |
|------|-----------|--------|
| Week 1 | Project Setup & Planning | ✅ |
| Week 2 | IoT Data Simulation | ✅ |
| Week 3 | Smart Contract Data Storage/Development | |
| Week 4 | Blockchain Ledger Draft | |
| Week 5 | Blockchain Ledger Submission | |
| Week 6 | Data Retrieval & Processing | |
| Week 7 | Line Plot of IoT Sensor Readings | |

---

## Group Members

- Abdelfattah, Rania Nabil
- Cajucom, Martin Sheen 
- De Lara, Chadley Marie
- Manicad, Karissa Mae
- Tantoco, Helena Rose 
- Villaverde III, Eugenio 
