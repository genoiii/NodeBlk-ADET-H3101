// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract IoTDataStorage {

    enum GoodsCategory {
        DeepFreeze, Frozen, ChillRefrigerated, Pharma, CoolChain, DryGoods, Electronics, Clothing, Industrial}

        struct Shipment {
            string rfidTag;
            GoodsCategory category;
            string origin;
            string destination;
            uint16 packageCount;
            string vehicleId;
            string driverId;
            uint256 registeredAt;
            bool exists;
        }

        struct IoTData {
            uint256 timestamp;
            string readingId;
            string rfidTag;
            string deviceId;
            string deviceType;
            string dataType;
            string dataValue;
            address recordedBy;
        }

        struct GPSRecord {
            uint256 timestamp;
            string rfidTag;
            string deviceId;
            string latitude;
            string longitude;
            address recordedBy;
        }

        struct TempRecord {
            uint256 timestamp;
            string rfidTag;
            string deviceId;
            int16 tempTimes10;
            address recordedBy;
        }

        struct RFIDRecord {
            uint256 timestamp;
            string rfidTag;
            string deviceId;
            string status;
            address recordedBy;
        }

        uint256 public constant MAX_ENTRIES = 100;
        address public owner;

        mapping(string => Shipment) private shipments;
        string[] public rfidTags;
        IoTData [] public iotRecords;
        GPSRecord[] public gpsRecords;
        TempRecord[] public tempRecords;
        RFIDRecord[] public rfidRecords;

        event ShipmentRegistered(string indexed rfidTag, string origin, string destination, uint8 category);
        event DataStored(uint256 timestamp, string indexed rfidTag, string deviceId, string dataType, string dataValue);
        event LocationStored(uint256 timestamp, string indexed rfidTag, string deviceId, string latitude, string longitude);
        event TemperatureStored(uint256 timestamp, string indexed rfidTag, string deviceId, int16 tempTimes10);
        event RFIDScanned(uint256 timestamp, string indexed rfidTag, string deviceId, string status);

        modifier onlyOwner() {
            require(msg.sender == owner, "Not authorized.");
            _;
        }

        modifier shipmentExists(string memory rfidTag) {
            require(shipments[rfidTag].exists, "Shipment not registered.");
            _;
        }

        modifier withinLimit(uint256 currentLength) {
        require(currentLength < MAX_ENTRIES, "Storage limit reached");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

        //Register a shipment before storing any sensor data

        function registerShipment(
            string memory rfidTag, GoodsCategory category,
            string memory origin, string memory destination,
            uint16 packageCount, string memory vehicleId, string memory driverId
        ) external onlyOwner {
            require(!shipments[rfidTag].exists, "Already registered.");
            require(bytes(rfidTag).length > 0, "rfidTag required.");
            require(bytes(origin).length > 0, "origin required.");
            require(bytes(destination).length > 0, "destination required.");
            
            shipments[rfidTag] = Shipment({
                rfidTag: rfidTag, category: category, origin: origin,
                destination: destination, packageCount: packageCount,
                vehicleId: vehicleId, driverId: driverId,
                registeredAt: block.timestamp, exists: true
            });
            rfidTags.push(rfidTag);
            emit ShipmentRegistered(rfidTag, origin, destination, uint8(category));
                    }

        // Generic store for dataType
        function storeData(
            string memory readingId, string memory rfidTag,
            string memory deviceId, string memory deviceType,
            string memory dataType, string memory dataValue
        ) external onlyOwner shipmentExists(rfidTag) withinLimit(iotRecords.length) {
            iotRecords.push(IoTData({
                timestamp: block.timestamp,
                readingId: readingId,
                rfidTag: rfidTag,
                deviceId: deviceId,
                deviceType: deviceType,
                dataType: dataType,
                dataValue: dataValue,
                recordedBy: msg.sender
            }));
            emit DataStored(block.timestamp, rfidTag, deviceId, dataType, dataValue);
        }
   
        // Store temperature
        function storeTemperature(
            string memory rfidTag, string memory deviceId, int16 tempTimes10
        ) external onlyOwner shipmentExists(rfidTag) withinLimit(tempRecords.length) {
            tempRecords.push(TempRecord({
                timestamp: block.timestamp, rfidTag: rfidTag,
                deviceId: deviceId, tempTimes10: tempTimes10, recordedBy: msg.sender
            }));
            emit TemperatureStored(block.timestamp, rfidTag, deviceId, tempTimes10);
        }

        //Store GPS
        function storeGPS(
            string memory rfidTag, string memory deviceId,
            string memory latitude, string memory longitude
        ) external onlyOwner shipmentExists(rfidTag) withinLimit(gpsRecords.length) {
            gpsRecords.push(GPSRecord({
                timestamp: block.timestamp,
                rfidTag: rfidTag,
                deviceId: deviceId,
                latitude: latitude,
                longitude: longitude,
                recordedBy: msg.sender
            }));
            emit LocationStored(block.timestamp, rfidTag, deviceId, latitude, longitude);
        }

        //Store RFID scan result
        function storeRFIDScan(
        string memory rfidTag, string memory deviceId, string memory status
        ) external onlyOwner shipmentExists(rfidTag) withinLimit(rfidRecords.length) {
            rfidRecords.push(RFIDRecord({
             timestamp: block.timestamp,
                rfidTag: rfidTag,
                deviceId: deviceId,
                status: status,
                recordedBy: msg.sender
            }));
            emit RFIDScanned(block.timestamp, rfidTag, deviceId, status);
        }

        function getShipment(string memory rfidTag) external view returns (Shipment memory) {
            require(shipments[rfidTag].exists, "Shipment not found.");
            return shipments[rfidTag];
        }

        function getAllRFIDTags() external view returns (string[] memory) { return rfidTags; }
        function shipmentCount()  external view returns (uint256) { return rfidTags.length; }
        function iotRecordCount() external view returns (uint256) { return iotRecords.length; }
        function gpsRecordCount() external view returns (uint256) { return gpsRecords.length; }
        function tempRecordCount() external view returns (uint256) { return tempRecords.length; }
        function rfidRecordCount() external view returns (uint256) { return rfidRecords.length; }

    function getLocationsByRFID(string memory rfidTag) external view returns (GPSRecord[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < gpsRecords.length; i++)
            if (_strEq(gpsRecords[i].rfidTag, rfidTag)) count++;
        GPSRecord[] memory result = new GPSRecord[](count);
        uint256 idx = 0;
        for (uint256 j = 0; j < gpsRecords.length; j++)
            if (_strEq(gpsRecords[j].rfidTag, rfidTag)) result[idx++] = gpsRecords[j];
        return result;
    }

    function getTemperaturesByRFID(string memory rfidTag) external view returns (TempRecord[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < tempRecords.length; i++)
            if (_strEq(tempRecords[i].rfidTag, rfidTag)) count++;
       TempRecord[] memory result = new TempRecord[](count);
        uint256 idx = 0;
        for (uint256 i = 0; i < tempRecords.length; i++)
            if (_strEq(tempRecords[i].rfidTag, rfidTag)) result[idx++] = tempRecords[i];
        return result; 
    }

    function getRFIDScansByRFID(string memory rfidTag) external view returns (RFIDRecord[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < rfidRecords.length; i++)
          if (_strEq(rfidRecords[i].rfidTag, rfidTag)) count++;
        RFIDRecord[] memory result = new RFIDRecord[](count);
         uint256 idx = 0;
         for (uint256 i = 0; i < rfidRecords.length; i++)
            if (_strEq(rfidRecords[i].rfidTag, rfidTag)) result[idx++] = rfidRecords[i];
        return result;
    }   

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }

    function _strEq(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}