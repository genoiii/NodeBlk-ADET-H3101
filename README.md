# Smart Logistics IoT Tracking System — carGO PH

> MO-IT148 — Applications Development and Emerging Technologies <br>
> Section: H3101 <br>
> Group: NodeBlk <br>
> Last Updated: May 27, 2026

---

## Project Overview

A blockchain-powered logistics tracking system developed for the Applications Development and Emerging Technologies class (MO-IT148). This repository contains the Milestone 1 submission — integrating IoT data simulation with on-chain storage via Web3.py. It simulates GPS, RFID, and temperature sensor readings across 30 shipments and stores them on a local blockchain through a Solidity smart contract deployed on Ganache.

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
- Web3.py blockchain integration pipeline
  - Ganache connection check with ConnectionError guard
  - Contract recognition via ABI loaded from compiled artifact
  - Type-routed bulk write — GPS, Temperature, and RFID readings each routed to specialized contract functions
  - Try/except per row to skip failures without stopping the loop
  - Post-write verification across all five on-chain counters

---

## Tech Stack

- Python
- pandas, numpy, random
- web3
- Jupyter Notebook
- Remix IDE (Solidity 0.8.18)
- Ganache (local Ethereum blockchain)

---

## Project Structure

```
├── contracts/
│   ├── IoTDataStorage.sol            ← Solidity smart contract source
│   ├── IoTDataStorage_compData.json  ← compiled ABI used by the notebook
│   ├── IoTDataStorage.json           ← legacy ABI artifact (kept for reference)
│   ├── artifacts/                    ← Remix compile output (metadata, build-info)
│   ├── remix.config.json             ← Remix workspace config
│   └── scenario1.json                ← Remix deployment record (address + ABI)
├── data/
│   ├── shipment_registry.csv         ← shipment metadata
│   ├── gps_readings.csv              ← GPS sensor readings
│   ├── rfid_readings.csv             ← RFID checkpoint scan readings
│   ├── temperature_readings.csv      ← temperature sensor readings
│   ├── iot_data.csv                  ← unified IoT feed sorted by timestamp
│   └── ph.csv                        ← Philippine city reference data (coordinates)
├── docs/
│   ├── Code Template.pdf             ← Week 4-5 reference template
│   ├── MO-IT148 Milestone 1.pdf      ← submission worksheet
│   └── group-docs/                   ← brainstorming + Week 2 design proposal
├── notebooks/
│   ├── smart-logistics-iot-simulation.ipynb           ← Week 2 IoT data simulation
│   └── smart-logistics-blockchain-integration.ipynb   ← Week 4-5 Web3.py pipeline
├── requirements.txt
└── README.md
```

---

## Notebook Documentation

### `smart-logistics-iot-simulation.ipynb` — Week 2 IoT Data Simulation
Generates the synthetic IoT dataset used by the blockchain integration pipeline. Produces all CSVs in `data/`:
- Builds the shipment registry across 30 packages with goods category, origin, destination, vehicle, and driver fields
- Simulates GPS readings using real Philippine city coordinates (`ph.csv`) and route interpolation
- Simulates RFID checkpoint scans with verified/flagged statuses
- Simulates temperature readings for cold-chain and temp-regulated shipments only
- Exports per-sensor CSVs plus a unified `iot_data.csv` sorted by timestamp

### `smart-logistics-blockchain-integration.ipynb` — Week 4-5 Web3.py Pipeline
End-to-end blockchain integration in six labeled sections.

**Section 1 — Ganache Connection**
Connects Web3.py to a local Ganache instance on RPC port `7545`. Raises `ConnectionError` if Ganache is unreachable. Prints the latest block number on success.

**Section 2 — Contract Load**
Loads the compiled contract ABI from `contracts/IoTDataStorage_compData.json` via `json.load()` and instantiates the contract using a `contract_config` dict pairing address + ABI. Sets `web3.eth.default_account = web3.eth.accounts[0]` so writes go through the deployer (required by the `onlyOwner` modifier). Prints the pre-write `iotRecordCount()` as a baseline.

**Section 3 — Dummy Test Transaction**
Registers a single test shipment (`TEST-001`) before calling `storeData()` with a dummy IoT record — needed because all sensor writes require the `shipmentExists` modifier to pass. Reads the record back via `iotRecords(0)` to confirm it landed on-chain.

**Section 3b — Type-Specific Record Helpers**
Defines four typed helper functions used by Section 4:
- `store_gps_record(rfid_tag, device_id, data_value)` — splits coordinate string and calls `storeGPS()`
- `store_temperature_record(rfid_tag, device_id, data_value)` — converts float to `int16` via `int(float(value) * 10)` and calls `storeTemperature()`
- `store_rfid_record(rfid_tag, device_id, data_value)` — calls `storeRFIDScan()`
- `store_generic_record(reading_id, rfid_tag, device_id, data_type, data_value)` — fallback path that calls `storeData()`

Each helper prints a confirmation line in the format: `data_type | rfid_tag | data_value | Txn: [hash]`.

**Section 3c — CSV Data Preview**
Loads `iot_data.csv` into a pandas DataFrame and prints the total record count alongside the first three rows. Serves as a quick sanity check confirming the dataset is accessible and correctly structured before the bulk write in Section 4.

**Section 4 — CSV Load + Bulk Write (`run_bulk_write()`)**
Two-step pipeline. First registers all 30 shipments from `shipment_registry.csv` using a `CATEGORY_MAP` dict to convert the `goods_category` string into the Solidity `GoodsCategory` enum index. Then iterates `iot_data.csv` and routes each row by `data_type` to the correct helper from Section 3b. Each row is wrapped in try/except so a single failure does not abort the loop. `time.sleep(0.5)` between successful writes prevents nonce conflicts.

**Section 5 — Verification (`run_verification()`)**
Reads and prints all five on-chain counters — `shipmentCount()`, `iotRecordCount()`, `gpsRecordCount()`, `tempRecordCount()`, `rfidRecordCount()` — then retrieves and prints the first real shipment from `shipment_registry.csv` by calling `getAllRFIDTags()[1]` (index `[1]` skips the `TEST-001` dummy registered in Section 3) and `getShipment()` on that tag. Also retrieves the first real GPS record from `iot_data.csv` via `gpsRecords(0)` and prints its timestamp, RFID tag, device ID, latitude, and longitude. Confirms data was correctly routed into separate on-chain arrays per data type.

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
   pip install -r requirements.txt
   ```

5. Generate the IoT dataset (optional — CSVs are already included)
   ```
   jupyter notebook notebooks/smart-logistics-iot-simulation.ipynb
   ```

### Smart Contract Deployment

#### Ganache Setup
1. Open Ganache and click **Quickstart Ethereum** to start a local blockchain
2. Go to **Settings** (gear icon) → **Chain** tab and increase the **Gas Limit** to at least **5,000,000** — the default may be too low and can cause out-of-gas errors at deployment

#### Remix Setup
1. Open [Remix IDE](https://remix.ethereum.org) and upload `contracts/IoTDataStorage.sol`
2. In the Solidity Compiler tab, select compiler version **0.8.18** and compile the contract
3. In Remix, go to the **Deploy & Run Transactions** tab and select **External HTTP Provider** as the environment, pointing to the Ganache RPC endpoint (`http://127.0.0.1:7545`)
4. Deploy the contract and copy the deployed contract address

### Blockchain Integration

1. Ensure Ganache is running on port **7545** and the contract is deployed
2. Open the integration notebook
   ```
   jupyter notebook notebooks/smart-logistics-blockchain-integration.ipynb
   ```
3. In Section 2, update the `address` field inside `contract_config` with the contract address from your Remix deployment — this changes on every redeployment
4. Run all cells in order from Section 1 through Section 5
5. Section 5 prints a verification summary of all records stored on-chain

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
