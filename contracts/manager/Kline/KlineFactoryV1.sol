// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseKline.sol";
import "../../utils/StringUtils.sol";
import "../../interface/IKlineManager.sol";
import "../../utils/Constance.sol";
import "hardhat/console.sol";

contract KlineFactoryV1 {
    // symbol -> interval -> time -> data
    mapping(bytes32 => mapping(Interval => mapping(uint64 => address)))
        public storages;
    // lưu các timekeys của 1 interval đẻ biết đã tạo bao nhiêu contract
    mapping(bytes32 => mapping(Interval => uint64[])) public allTimekeys;
    event KlineContractCreated(uint256 key, address contractAddress);
    event ShardCreated(
        string symbol,
        string interval,
        uint64 timeKey,
        address storageAddress
    );
    event KlineCreated(uint64 t, uint256 T, bool isClose);

    // lưu trong 1 h
    function getTimeKey(Interval, uint64 timestamp)
        internal
        pure
        returns (uint64)
    {
        return (timestamp / Constance.STEP_1S) * (Constance.STEP_1S);
    }

    function addKline(KlineRecord memory record) public {
        // parse interval
        Interval interval = parseInterval(record.i);
        bytes32 symbolKey = keccak256(abi.encodePacked(record.s));
        //test
        uint64 key = getTimeKey(interval, record.t);

        address storageAddr = storages[symbolKey][interval][key];
        if (storageAddr == address(0)) {
            allTimekeys[symbolKey][interval].push(key);
            storageAddr = address(new BaseKline());
            storages[symbolKey][interval][key] = storageAddr;
            emit ShardCreated(record.s, record.i, key, storageAddr);
        }
        IKlineManager(storageAddr).recordKline(record);
        emit KlineCreated(record.t, record.T, record.x);
    }

    function getLengthKline(
        string memory _symbol,
        string memory _interval,
        uint64 timestime
    ) public view returns (uint256) {
        Interval interval = parseInterval(_interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));
        uint64 key = getTimeKey(interval, timestime);
        address storageAddr = storages[symbolKey][interval][key];
        require(storageAddr != address(0), "Address is not found");
        return IKlineManager(storageAddr).getLength();
    }

    function getAllklineInTime(
        string memory _symbol,
        string memory _interval,
        uint64 timestime
    ) public view returns (KlineResponse[] memory) {
        Interval interval = parseInterval(_interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));
        uint64 key = getTimeKey(interval, timestime);
        address storageAddr = storages[symbolKey][interval][key];
        require(storageAddr != address(0), "Address is not found");
        return IKlineManager(storageAddr).getAllKline();
    }

    // get theo starttime và endtime
    function getAllRecords(
        string memory _symbol,
        string memory _interval,
        uint64 startTime,
        uint64 endTime,
        uint256 limit
    ) public view returns (KlineResponse[] memory result) {
        Interval interval = parseInterval(_interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));

        // Compute all possible timeKeys from endTime to startTime in reverse
        // tính toán khoảng thời gian cần lấy nến
        uint64[] memory timeKeys = computeTimeKeys(
            interval,
            startTime,
            endTime
        );

        uint256 count;
        KlineResponse[] memory temp = new KlineResponse[](limit);
        // lặp ngược lại vì nó là 12h 13h ,
        for (uint256 i = timeKeys.length; i > 0; i--) {
            address storageAddr = storages[symbolKey][interval][
                timeKeys[i - 1]
            ];
            if (storageAddr == address(0)) continue;
            // cần tối ưu đoạn này nếu k tối ưu được time key
            KlineResponse[] memory records = IKlineManager(storageAddr)
                .getAllKline();
            for (uint256 j = records.length; j > 0; j--) {
                KlineResponse memory c = records[j - 1];
                if (c.k.t >= startTime && c.k.T <= endTime) {
                    temp[count++] = c;
                    if (count == limit) break;
                }
            }
            if (count == limit) break;
        }

        // Copy to exact size array
        result = new KlineResponse[](count);
        for (uint256 i = count; i > 0; i--) {
            result[count - i] = temp[i - 1];
        }
    }

    function computeTimeKeys(
        Interval interval,
        uint64 startTime,
        uint64 endTime
    ) internal pure returns (uint64[] memory keys) {
        uint64 step = 2 * 60 * 60 * 1000; // vì là lưu trong 2h, nếu trên kia lưu giờ khác thì đổi lại
        uint64 from = getTimeKey(interval, startTime);
        uint64 to = getTimeKey(interval, endTime);
        uint256 count;
        // ví dụ nến 1s
        // TH: 1h -> 2h
        if (startTime == from && endTime == to) {
            count = (to - from) / step;
        } else {
            // TH: 1h -> 2h30: 1h-2h , 1h30 -> 2h30: 1h-2h, 1h30 -> 1h45
            count = ((to - from) / step) + 1;
        }
        keys = new uint64[](count);

        for (uint256 i = 0; i < count; i++) {
            keys[i] = from + uint64(i * step);
        }
    }

    function getAllTimeKeys(string memory _symbol, string memory _interval)
        public
        view
        returns (uint64[] memory)
    {
        Interval interval = parseInterval(_interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));
        return allTimekeys[symbolKey][interval];
    }

    function getLengthTimeKeys(string memory _symbol, string memory _interval)
        public
        view
        returns (uint256)
    {
        Interval interval = parseInterval(_interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));
        return allTimekeys[symbolKey][interval].length;
    }

    function parseInterval(string memory s) internal pure returns (Interval) {
        bytes32 h = keccak256(abi.encodePacked(s));

        if (h == Constance.INTERVAL_1S) return Interval.OneSecond;
        else if (h == Constance.INTERVAL_1M) return Interval.OneMinute;
        else if (h == Constance.INTERVAL_3M) return Interval.ThreeMinutes;
        else if (h == Constance.INTERVAL_5M) return Interval.FiveMinutes;
        else if (h == Constance.INTERVAL_15M) return Interval.FifteenMinutes;
        else if (h == Constance.INTERVAL_30M) return Interval.ThirtyMinutes;
        else if (h == Constance.INTERVAL_1H) return Interval.OneHour;
        else if (h == Constance.INTERVAL_2H) return Interval.TwoHours;
        else if (h == Constance.INTERVAL_4H) return Interval.FourHours;
        else if (h == Constance.INTERVAL_6H) return Interval.SixHours;
        else if (h == Constance.INTERVAL_8H) return Interval.EightHours;
        else if (h == Constance.INTERVAL_12H) return Interval.TwelveHours;
        else if (h == Constance.INTERVAL_1D) return Interval.OneDay;
        else if (h == Constance.INTERVAL_3D) return Interval.ThreeDays;
        else if (h == Constance.INTERVAL_1W) return Interval.OneWeek;
        else if (h == Constance.INTERVAL_1MO) return Interval.OneMonth;
        else revert("Unsupported interval");
    }
}
