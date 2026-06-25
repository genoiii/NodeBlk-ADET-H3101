# Smart Logistics IoT Tracking System — carGO PH

> MO-IT148 — Applications Development and Emerging Technologies <br>
> Section: H3101 <br>
> Group: NodeBlk <br>
> Last Updated: June 25, 2026

---

## Project Overview

A blockchain-powered logistics tracking system developed for the Applications Development and Emerging Technologies class (MO-IT148). This repository tracks the full project across Weeks 2–7, integrating IoT data simulation with on-chain storage via Web3.py. It simulates GPS, RFID, and temperature sensor readings across shipments and stores them on a local blockchain through a Solidity smart contract deployed on Ganache.

**v2 notebooks** (Week 9 revisions) scale the simulation up and add richer data — see the [Weekly Progress](#weekly-progress) section and each notebook's documentation for what changed.

---

## Features

- IoT sensor data simulation
  - GPS coordinate tracking with real Philippine city coordinates and route interpolation
  - RFID checkpoint scanning with verified/flagged status
  - Temperature monitoring for cold-chain and temp-regulated goods
- Shipment registry with goods category, origin, destination, vehicle, driver data, scheduled/actual delivery datetimes, shipment status, and delay reason
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
- Blockchain data retrieval, cleaning, and enrichment
  - Records pulled directly from chain and assembled into a unified DataFrame
  - 25-column cleaned output with computed fields: `temp_breach`, `breach_delta_c`, `is_flagged`, `scan_hour`, `scan_day`, `delay_hours`
  - Shipment registry joined for operational context (status, delivery datetimes, delay reason)
- IoT sensor line plot visualization
  - Three-panel chart: GPS latitude over time, temperature (°C) over time with breach markers, RFID flagged scans per hour
  - Covers full sensor timeline from simulation start to end

---

## Tech Stack

- Python
- pandas, numpy, random, matplotlib, seaborn
- web3
- Jupyter Notebook
- Remix IDE (Solidity 0.8.18)
- Ganache (local Ethereum blockchain)

---

## Project Structure

```
├── contracts/
│   ├── IoTDataStorage.sol            ← Solidity smart contract source
│   ├── IoTDataStorage_compData.json  ← compiled ABI used by the notebooks
│   ├── IoTDataStorage.json           ← legacy ABI artifact (kept for reference)
│   ├── artifacts/                    ← Remix compile output (metadata, build-info)
│   ├── remix.config.json             ← Remix workspace config
│   └── scenario1.json                ← Remix deployment record (address + ABI)
├── data/
│   ├── 1-shipment_registry_v2.csv    ← shipment metadata (50 rows, 11 columns)
│   ├── 2-gps_readings_v2.csv         ← GPS sensor readings (400 rows)
│   ├── 3-rfid_readings_v2.csv        ← RFID checkpoint scan readings (226 rows)
│   ├── 4-temperature_readings_v2.csv ← temperature sensor readings (240 rows)
│   ├── 5-iot_data_v2.csv             ← unified IoT feed sorted by timestamp (866 rows)
│   ├── 6-iot_cleaned_data_v2.csv     ← cleaned & enriched IoT data (866 rows, 25 columns)
│   ├── 7-sensor_stats_summary_v2.csv ← per-sensor descriptive stats summary
│   ├── iot_sensor_readings_over_time_v2.png ← Week 7 three-panel line plot
│   └── ph.csv                        ← Philippine city reference data (coordinates)
├── notebooks/
│   ├── 1-smart-logistics-iot-simulation-v2.ipynb          ← Week 2 IoT data simulation (v2)
│   ├── 2-smart-logistics-blockchain-integration-v2.ipynb  ← Week 4-5 Web3.py pipeline (v2)
│   ├── 3-blockchain-data-retrieval-v2.ipynb               ← Week 6 retrieval, cleaning & stats (v2)
│   └── 4-iot-sensor-line-plot-v2.ipynb                    ← Week 7 line plot visualization (v2)
├── requirements.txt
└── README.md
```

---

## Notebook Documentation

### `1-smart-logistics-iot-simulation-v2.ipynb` — Week 2 IoT Data Simulation
Generates the synthetic IoT dataset used by the blockchain integration pipeline. Produces all CSVs in `data/`:
- Builds the shipment registry across **50 shipments** (up from 30) with goods category, origin, destination, vehicle, and driver fields
- **New in v2:** shipment registry now includes `scheduled_delivery_dt`, `actual_delivery_dt`, `shipment_status` (80% Delivered / 20% Delayed), and `delay_reason` (Route change, Weather, RFID flag, Temp breach, Traffic)
- Simulates GPS readings using real Philippine city coordinates (`ph.csv`) and route interpolation — **8 readings per shipment** (up from 5), **3-day departure window** (up from 2)
- Simulates RFID checkpoint scans — **3–6 scans per shipment** (up from 2–4), **25% flag rate** (up from 15%)
- Simulates temperature readings for cold-chain and temp-regulated shipments only — **20% breach rate** (up from 10%)
- Uses `random.seed(42)` for reproducible output
- Exports five versioned CSVs; see summary output for exact row counts

**v2 Simulation Summary:**
```
Total shipments:             50  (30 temp-regulated, 20 non-temp)
GPS readings:                400
RFID readings:               226  (flagged: 52)
Temperature readings:        240
Total iot_data_v2.csv rows:  866
```

### `2-smart-logistics-blockchain-integration-v2.ipynb` — Week 4-5 Web3.py Pipeline
End-to-end blockchain integration in six labeled sections. Updated in v2 to consume the larger v2 CSV files.

**Section 1 — Ganache Connection**
Connects Web3.py to a local Ganache instance on RPC port `7545`. Raises `ConnectionError` if Ganache is unreachable. Prints the latest block number on success.

**Section 2 — Contract Load**
Loads the compiled contract ABI from `contracts/IoTDataStorage_compData.json` and instantiates the contract. Sets `web3.eth.default_account = web3.eth.accounts[0]`. Prints the pre-write `iotRecordCount()` as a baseline.

**Section 3 — Dummy Test Transaction**
Registers a single test shipment (`TEST-001`) and stores a dummy IoT record to confirm the pipeline works before the bulk write.

**Section 3b — Type-Specific Record Helpers**
Defines four typed helper functions: `store_gps_record()`, `store_temperature_record()`, `store_rfid_record()`, and `store_generic_record()` (fallback).

**Section 3c — CSV Data Preview**
Loads `5-iot_data_v2.csv` and prints the record count and first three rows as a pre-write sanity check.

**Section 4 — CSV Load + Bulk Write (`run_bulk_write()`)**
Registers all 50 shipments from `1-shipment_registry_v2.csv` using a `CATEGORY_MAP` dict, then iterates `5-iot_data_v2.csv` and routes each row by `data_type` to the correct helper. Try/except per row; `time.sleep(0.5)` between writes.

**Section 5 — Verification (`run_verification()`)**
Reads and prints all five on-chain counters, retrieves the first real shipment via `getAllRFIDTags()[1]`, and reads back the first IoT record from the correct typed array based on the first row of the CSV.

### `3-blockchain-data-retrieval-v2.ipynb` — Week 6 Data Retrieval & Cleaning
Retrieves all IoT records from the IoTDataStorage smart contract, cleans and enriches the data, and exports two CSVs for analysis and Tableau.

**Section 1 — Setup**
Connects to Ganache, loads the contract ABI, and confirms record counts on chain (GPS: 400, Temp: 240, RFID: 226).

**Section 2 — Retrieval**
Pulls all GPS, Temperature, and RFID records from the contract's public arrays into separate DataFrames.

**Section 3 — DataFrame Construction**
Concatenates the three sensor DataFrames into one unified table of 866 rows.

**Section 4 — Cleaning & Enrichment**
- Converts blockchain Unix timestamps to datetime (`blockchain_timestamp`)
- Joins `sensor_timestamp` from `5-iot_data_v2.csv` by `rfid_tag` + `device_id`
- Decodes temperature from int16 × 10 format back to float °C
- Pulls `goods_category`, `origin`, `destination` from chain via `getShipment()`
- Computes `temp_breach` (bool), `breach_delta_c` (how far above safe max), `is_flagged` (bool)
- Joins `package_count`, `vehicle_id`, `driver_id`, `shipment_status`, `scheduled_delivery_dt`, `actual_delivery_dt`, `delay_reason` from `1-shipment_registry_v2.csv`
- Adds `scan_hour`, `scan_day`, and `delay_hours` computed columns
- Filters out `TEST-001` dummy record
- **Final output: 866 rows × 25 columns** (up from 14 columns in v1)

**Section 5 — RFID Filter**
Groups the cleaned DataFrame by `rfid_tag` and confirms all 50 shipments are present.

**Section 6 — Stats**
Computes per-sensor descriptive statistics (mean, min, max, std) and saves to `7-sensor_stats_summary_v2.csv`.

**Section 7 — Export**
Writes `6-iot_cleaned_data_v2.csv` (866 rows, 25 columns) and `7-sensor_stats_summary_v2.csv`.

**25-column schema of `6-iot_cleaned_data_v2.csv`:**
`blockchain_timestamp`, `sensor_timestamp`, `rfid_tag`, `device_id`, `sensor_type`, `latitude`, `longitude`, `scan_status`, `temperature_c`, `is_flagged`, `temp_breach`, `breach_delta_c`, `goods_category`, `origin`, `destination`, `package_count`, `vehicle_id`, `driver_id`, `shipment_status`, `scheduled_delivery_dt`, `actual_delivery_dt`, `delay_reason`, `delay_hours`, `scan_hour`, `scan_day`

### `4-iot-sensor-line-plot-v2.ipynb` — Week 7 Line Plot
Visualizes the cleaned IoT sensor data from `6-iot_cleaned_data_v2.csv`. Covers the full sensor timeline from 2026-05-03 to 2026-05-07.

**Section 1 — Setup**
Imports matplotlib, seaborn, and pandas. Defines fixed per-sensor colors: blue (GPS), red (Temperature), green (RFID).

**Section 2 — Load Cleaned Data**
Loads `6-iot_cleaned_data_v2.csv` (866 records) and confirms sensor type breakdown and time range.

**Section 3 — Plot**
Produces a three-panel figure saved as `iot_sensor_readings_over_time_v2.png`:
- **Top panel (blue)** — GPS latitude over time, one line per shipment showing route interpolation from origin to destination
- **Middle panel (red)** — Temperature (°C) over time per shipment, with `×` markers on breach readings
- **Bottom panel (green)** — RFID flagged scans aggregated per hour as a bar/line chart

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

5. Generate the IoT dataset (optional — v2 CSVs are already included in `data/`)
   ```
   jupyter notebook notebooks/1-smart-logistics-iot-simulation-v2.ipynb
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
   jupyter notebook notebooks/2-smart-logistics-blockchain-integration-v2.ipynb
   ```
3. In Section 2, update the `address` field inside `contract_config` with the contract address from your Remix deployment — this changes on every redeployment
4. Run all cells in order from Section 1 through Section 5

### Data Retrieval & Visualization

After the bulk write completes:
```
jupyter notebook notebooks/3-blockchain-data-retrieval-v2.ipynb
jupyter notebook notebooks/4-iot-sensor-line-plot-v2.ipynb
```
Both notebooks read the same contract address used in the integration notebook — update it in Section 1 of the retrieval notebook if you redeployed.

---

## Weekly Progress

| Week | Milestone | Status |
|------|-----------|--------|
| Week 1 | Project Setup & Planning | ✅ |
| Week 2 | IoT Data Simulation | ✅ |
| Week 3 | Smart Contract Data Storage/Development | ✅ |
| Week 4 | Blockchain Ledger Draft | ✅ |
| Week 5 | Blockchain Ledger Submission | ✅ |
| Week 6 | Data Retrieval & Processing | ✅ |
| Week 7 | Line Plot of IoT Sensor Readings | ✅ |
| Week 9 | v2 Revisions (all notebooks & data) | ✅ |

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