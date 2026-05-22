# Smart Logistics IoT Tracking System — carGO PH

> MO-IT148 — Applications Development and Emerging Technologies <br>
> Section: H3101 <br>
> Group: NodeBlk <br>
> Last Updated: May 22, 2026

---

## Project Overview

A blockchain-powered logistics tracking system developed for the Applications Development and Emerging Technologies class (MO-IT148). This repository currently contains the IoT data simulation and the smart contract data storage layer for Milestone 1, focused on package tracking, supply chain transparency, and fraud prevention. It simulates GPS, RFID, and temperature sensor readings across 30 shipments and stores them on a local blockchain through a Solidity smart contract deployed on Ganache.

---

## Features

- IoT sensor data simulation
  - GPS coordinate tracking with real Philippine city coordinates and route interpolation
  - RFID checkpoint scanning with verified/flagged status
  - Temperature monitoring for cold-chain and temp-regulated goods
- Shipment registry with goods category, origin, destination, vehicle, and driver data
- Separate CSV exports per sensor type plus a unified IoT data feed
- Smart contract data storage on a local Ethereum blockchain
  - Shipment registration with goods category enum
  - On-chain storage of GPS, RFID, and temperature readings
  - Per-shipment query functions for retrieving sensor history
  - Owner-restricted writes and ownership transfer
- Blockchain ledger integration
  - Web3.py connection to Ganache local blockchain
  - Draft script for connection testing and dummy transaction verification
  - Full submission script that registers all 30 shipments and uploads 329 IoT records on-chain
  - On-chain verification of GPS, temperature, and RFID record counts

---

## Tech Stack

- Python
- pandas, numpy, random, web3.py
- Jupyter Notebook
- Remix IDE (Solidity 0.8.18)
- Ganache (local Ethereum blockchain)

---

## Project Structure

- `smart-logistics-iot-simulation.ipynb` — IoT data simulation notebook
- `blockchain-ledger-verification.ipynb` — Week 4 draft: connection test and dummy transaction
- `milestone-1-submission.ipynb` — Week 5 submission: full shipment registration and IoT data upload to blockchain
- `ph.csv` — Philippine city reference data (coordinates)
- `shipment_registry.csv` — shipment metadata (origin, destination, goods category, vehicle, driver)
- `gps_readings.csv` — GPS sensor readings per shipment
- `rfid_readings.csv` — RFID checkpoint scan readings
- `temperature_readings.csv` — temperature sensor readings (temp-regulated shipments only)
- `iot_data.csv` — unified IoT feed combining all sensor types, sorted by timestamp
- `IoTDataStorage.sol` — Solidity smart contract for on-chain data storage
- `scenario1.json` — Remix deployment record containing contract address and ABI
- `remix.config.json` — Remix IDE configuration

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

### Smart Contract Deployment

#### Ganache Setup

1. Open Ganache and click **Quickstart Ethereum** to start a local blockchain
2. Go to **Settings** (gear icon) → **Chain** tab and increase the **Gas Limit** to at least **5,000,000** — the default may be too low for this contract and can cause out-of-gas errors at deployment


### Smart Contract Deployment/Remix Setup
 
1. Open [Remix IDE](https://remix.ethereum.org) and upload `IoTDataStorage.sol`
2. In the Solidity Compiler tab, select compiler version **0.8.18** and compile the contract
3. Open Ganache and click **Quickstart Ethereum** to start a local blockchain
4. In Remix, go to the **Deploy & Run Transactions** tab and select **External HTTP Provider** as the environment, pointing to the Ganache RPC endpoint (default: `http://127.0.0.1:7545`)
5. Deploy the contract and save the contract address and ABI for later use


### Blockchain Ledger (Weeks 4 & 5)
 
1. Ensure Ganache is running and the contract is deployed
2. Open `blockchain-ledger-verification.ipynb` to verify the Web3 connection and test a dummy transaction
3. Open `milestone-1-submission.ipynb` to register all 30 shipments and upload all IoT sensor data to the blockchain
4. The final cell prints a verification summary of all records stored on-chain
---

## Weekly Progress

| Week | Milestone | Status |
|------|-----------|--------|
| Week 1 | Project Setup & Planning | ✅ |
| Week 2 | IoT Data Simulation | ✅ |
| Week 3 | Smart Contract Data Storage/Development | ✅ |
| Week 4 | Blockchain Ledger Draft | ✅ |
| Week 5 | Blockchain Ledger Submission | ✅ |
| Week 6 | Data Retrieval & Processing | |
| Week 7 | Line Plot of IoT Sensor Readings | |

---

## Group Members

| Name | Role |
|------|------|
| De Lara, Chadley Marie | Project Lead & Visualization Co-Lead |
| Abdelfattah, Rania Nabil | Blockchain Dev Co-Lead & Documentation |
| Cajucom, Martin Sheen | Blockchain Dev Lead & Documentation |
| Manicad, Karissa Mae | Data Quality Checker & Visualization Lead |
| Tantoco, Helena Rose | Integration Lead / Code QA & Tester |
| Villaverde III, Eugenio | IoT Simulation Data Developer Lead & Tester |
