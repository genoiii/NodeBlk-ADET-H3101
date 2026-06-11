# Smart Logistics IoT Tracking System — carGO PH

> MO-IT148 — Applications Development and Emerging Technologies (ADET) <br>
> Section: H3101 <br>
> Group: NodeBlk <br>
> Last Updated: June 11, 2026

---

## Project Overview

A blockchain-powered logistics tracking system developed for the Applications Development and Emerging Technologies class (MO-IT148). This repository contains the group's ADET submission — integrating IoT data simulation with on-chain storage via Web3.py, and full blockchain data retrieval and cleaning. It simulates GPS, RFID, and temperature sensor readings across 30 shipments, stores them on a local blockchain through a Solidity smart contract deployed on Ganache, retrieves and cleans the on-chain data into a structured, tidy dataset, and computes per-sensor statistics for downstream visualization.


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
- Blockchain data retrieval and cleaning pipeline
  - Full retrieval of GPS, Temperature, and RFID records from on-chain arrays
  - Dual-timestamp structure: blockchain write time (`blockchain_timestamp`) vs. original sensor time (`sensor_timestamp`)
  - Temperature decoding from `int16` × 10 back to float °C
  - Temperature breach detection per goods category against simulation-defined safe ranges
  - RFID flag derivation from `scan_status` without CSV lookup
  - Shipment metadata enrichment (goods category, origin, destination) via live `getShipment()` calls
  - NumPy descriptive statistics (mean, min, max, std) per sensor type
  - Export to `iot_cleaned_data.csv` and `sensor_stats_summary.csv`

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
│   ├── iot_cleaned_data.csv          ← cleaned blockchain-retrieved data with enriched columns
│   ├── sensor_stats_summary.csv      ← NumPy descriptive stats per sensor type
│   ├── iot_sensor_readings_over_time.png      ← Week 7 line plot saved at 150 DPI
│   └── ph.csv                        ← Philippine city reference data (coordinates)
├── notebooks/
│   ├── smart-logistics-iot-simulation.ipynb           ← Week 2 IoT data simulation
│   └── smart-logistics-blockchain-integration.ipynb   ← Week 4-5 Web3.py pipeline
│   └── blockchain-data-retrieval.ipynb                ← Week 6 data retrieval + cleaning + stats
│   └── iot-sensor-line-plot.ipynb                     ← Week 7 line plot visualization
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
Reads and prints all five on-chain counters — `shipmentCount()`, `iotRecordCount()`, `gpsRecordCount()`, `tempRecordCount()`, `rfidRecordCount()` — then retrieves and prints the first real shipment by calling `getAllRFIDTags()[1]` (index `[1]` skips the `TEST-001` dummy registered in Section 3) and `getShipment()` on that tag. Also dynamically retrieves the first real IoT record from the blockchain by reading the first row of `iot_data.csv` to determine its data type, then calling the correct contract array — `tempRecords(0)`, `gpsRecords(0)`, or `rfidRecords(0)` — to read the actual on-chain value. Confirms data was correctly routed into separate on-chain arrays per data type.

### `blockchain-data-retrieval.ipynb` — Week 6 Data Retrieval + Cleaning + Stats
End-to-end retrieval and analysis pipeline in eight labeled sections.

**Section 1 — Setup**
Imports, ABI load from `contracts/IoTDataStorage_compData.json`, contract instantiation, and Ganache connection confirmation. Prints on-chain counters for GPS (150), Temperature (95), and RFID (84) records as a pre-retrieval baseline. Ganache must be running with the contract deployed before this cell executes.

**Section 2 — Retrieval**
Loops through all three on-chain arrays — `gpsRecords`, `tempRecords`, `rfidRecords` — using their respective count functions as loop bounds. Collects raw tuples into typed row dicts and builds one DataFrame per sensor type. Prints a warning if any DataFrame comes back empty, which indicates a Ganache session mismatch.

**Section 3 — DataFrame Construction**
Concatenates the three sensor DataFrames into a single `iot_records_df` using `pd.concat(..., ignore_index=True)`. Columns absent for a given sensor type (e.g. `latitude` for Temperature rows) become `NaN`. Prints total record count (329) and column dtypes.

**Section 4 — Cleaning**
Applies all type conversions and data quality steps to produce `iot_cleaned_df`:
- Unix `blockchain_timestamp` → `datetime64` via `pd.to_datetime(..., unit='s')`
- `sensor_timestamp` joined from `iot_data.csv` on `rfid_tag + device_id` — the only CSV pull in the pipeline, needed because sensor timestamps were never stored on-chain
- `latitude` and `longitude` cast from string to float via `pd.to_numeric(..., errors='coerce')`
- `temperature_raw` (on-chain `int16`) divided by 10 to recover float °C, then the raw column is dropped
- `TEST-001` dummy excluded immediately after the sensor timestamp merge
- `is_flagged` boolean derived from `scan_status` comparison — no CSV lookup required
- `temp_breach` boolean computed per Temperature row by checking `temperature_c` against `TEMP_RANGES` for the shipment's goods category; non-temp-regulated rows and non-Temperature sensor rows return `None`
- `goods_category`, `origin`, and `destination` enriched via live `getShipment()` calls for every RFID tag returned by `getAllRFIDTags()`

**Section 5 — RFID Filter**
Groups `iot_cleaned_df` by `rfid_tag` using `groupby()`. Prints the number of unique shipments (30) and lists all group keys. The resulting `iot_by_rfid` GroupBy object is used in downstream per-shipment analysis via `.get_group("RFID-XXX")`.

**Section 6 — Stats**
Iterates sensor type groups and computes NumPy descriptive statistics — mean, min, max, std — for `latitude` (GPS rows) and `temperature_c` (Temperature rows). RFID rows are skipped as they have no numeric column. Results are collected into `sensor_stats_df` and printed.

**Section 7 — Export**
Exports two CSVs to `data/`:
- `iot_cleaned_data.csv` — full cleaned tidy dataset, primary input for Week 7 visualization
- `sensor_stats_summary.csv` — sensor-level summary table for dashboard stat cards

**Section 8 — Preview**
Displays the first 10 rows of `iot_cleaned_df` and prints final pipeline totals: 329 clean records, 30 unique shipments, sensor types `['GPS', 'Temperature', 'RFID']`.

### iot-sensor-line-plot.ipynb — Week 7 Line Plot of IoT Sensor Readings Over Time
Visualizes the cleaned IoT sensor data produced in Week 6 (iot_cleaned_data.csv). Each sensor type is plotted in its own color against the original sensor capture time, making patterns, trends, and anomalies easy to read.

**Section 1 - Setup**
Imports pandas, numpy, matplotlib, matplotlib.dates, and seaborn. Sets the visualization style via `sns.set_theme(style="whitegrid")`. Defines a SENSOR_COLORS dict assigning one fixed hex color per sensor type — blue for GPS, red for Temperature, green for RFID — reused across all panels and the legend.

**Section 2 — Load Cleaned Data**
Loads `iot_cleaned_data.csv` from the Week 6 export. Converts both `sensor_timestamp` and `blockchain_timestamp` to datetime. Sorts rows chronologically by `sensor_timestamp` so lines connect points in time order. Prints the total record count, sensor type breakdown, and time range.

**Section 3 — Line Plot: One Panel Per Sensor Type**
Primary deliverable. Each panel has a descriptive title and labeled y-axis. The shared x-axis uses `mdates.DateFormatter` with labels rotated 45°. The figure title reads "carGO PH — IoT Sensor Readings Over Time". Produces three stacked panels sharing a common time axis via `plt.subplots(3, 1, sharex=True)`:

- Panel 1 — GPS: plots `latitude` over time using `units="rfid_tag"` and `estimator=None` so each shipment gets its own line rather than being - averaged across shared timestamps
- Panel 2 — Temperature: plots `temperature_c` over time the same way; includes a dashed reference line at 0°C separating frozen from chilled goods
- Panel 3 — RFID: aggregates flagged scans into hourly counts via `dt.floor("h")` and `groupby`, then plots flagged scans per hour as a single line

Followed by a short written analysis covering key patterns, anomalies, and temperature breaches observed across all three sensor panels.

**Section 4 — Alternative: Single Overlay Plot**
Overlays GPS and Temperature on one axis for a direct side-by-side comparison using `hue="sensor_type"`, mirroring the Week 7 code template structure. A `numeric_value` column is constructed via `np.where` to unify latitude and temperature onto a shared axis. RFID is excluded as it has no comparable numeric value. The faceted panels in Section 3 are the primary deliverable since the differing scales make this view harder to read.

Section 5 — Save the Plot
Saves the faceted figure to `data/iot_sensor_readings_over_time.png` at 150 DPI using `bbox_inches="tight"`.

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

### Data Retrieval & Analysis
1. Ensure Ganache is still running with the same deployed contract
2. Open the retrieval notebook
   ```
   jupyter notebook notebooks/blockchain-data-retrieval.ipynb
   ```
3. In Section 1, update `CONTRACT_ADDRESS` to match the current Ganache deployment
4. Run all cells in order from Section 1 through Section 8
5. Section 7 exports `iot_cleaned_data.csv` and `sensor_stats_summary.csv` to `data/`
   
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
