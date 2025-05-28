// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CandleManagerV3.sol";
import "../../interface/ICandleManager.sol";
import "../../utils/Constance.sol";

// version 1 , interval lưu trong factory
contract CandleFactoryV3 {
    // symbol => interval => timeKey => storage contract
    mapping(bytes32 => mapping(Interval => mapping(uint64 => address)))
        public storages;
    // lưu các timekeys của 1 interval đẻ biết đã tạo bao nhiêu contract
    mapping(bytes32 => mapping(Interval => uint64[])) public allTimekeys;
    event ShardCreated(
        string indexed symbol,
        string indexed interval,
        uint64 indexed timeKey,
        address storageAddress
    );
    event KlineCreated(
        uint64 openTime,
        uint256 openPrice,
        uint256 highPrice,
        uint256 lowPrice,
        uint256 closePrice,
        uint256 volume,
        uint64 closeTime,
        uint256 quoteAssetVolume,
        uint32 numberOfTrades,
        uint256 takerBuyBaseVolume,
        uint256 takerBuyQuoteVolume,
        bool isClose
    );

    function getTimeKey(Interval interval, uint64 timestamp)
        internal
        pure
        returns (uint64)
    {
        if (interval == Interval.OneSecond)
            return (timestamp / Constance.STEP_1S) * Constance.STEP_1S;
        // 4 hours
        else if (interval == Interval.OneMinute)
            return (timestamp / Constance.STEP_1M) * Constance.STEP_1M;
        // 10 days
        else if (interval == Interval.ThreeMinutes)
            return (timestamp / Constance.STEP_3M) * Constance.STEP_3M;
        // 25 days
        else if (interval == Interval.FiveMinutes)
            return (timestamp / Constance.STEP_5M) * Constance.STEP_5M;
        // 35 days
        else if (interval == Interval.FifteenMinutes)
            return (timestamp / Constance.STEP_15M) * Constance.STEP_15M;
        // 90 days
        else if (interval == Interval.ThirtyMinutes)
            return (timestamp / Constance.STEP_30M) * Constance.STEP_30M;
        // 200 days
        else if (interval == Interval.OneHour)
            return (timestamp / Constance.STEP_1H) * Constance.STEP_1H;
        // 1 year
        else if (interval == Interval.TwoHours)
            return (timestamp / Constance.STEP_2H) * Constance.STEP_2H;
        // 2 years
        else if (interval == Interval.FourHours)
            return (timestamp / Constance.STEP_4H) * Constance.STEP_4H;
        // 4 years
        else if (interval == Interval.SixHours)
            return (timestamp / Constance.STEP_6H) * Constance.STEP_6H;
        // 6 years
        else if (interval == Interval.EightHours)
            return (timestamp / Constance.STEP_8H) * Constance.STEP_8H;
        // 8 years
        else if (interval == Interval.TwelveHours)
            return (timestamp / Constance.STEP_12H) * Constance.STEP_12H;
        // 12 years
        else if (interval == Interval.OneDay)
            return (timestamp / Constance.STEP_1D) * Constance.STEP_1D;
        // 24 years
        else if (interval == Interval.ThreeDays)
            return (timestamp / Constance.STEP_3D) * Constance.STEP_3D;
        // 72 years
        else if (interval == Interval.OneWeek)
            return (timestamp / Constance.STEP_1W) * Constance.STEP_1W;
        // 50 years
        else if (interval == Interval.OneMonth)
            return (timestamp / Constance.STEP_1MO) * Constance.STEP_1MO;
        // 100 years
        else revert("Unsupported interval");
    }

    function initCandle(string memory _symbol, string memory _interval)
        public
        view
        returns (address[] memory)
    {
        Interval interval = parseInterval(_interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));
        uint64[] storage timeKeys = allTimekeys[symbolKey][interval];
        require(timeKeys.length > 0, "No timeKeys available");

        // Lấy số lượng address cần trả (tối đa 2 hoặc ít hơn nếu không đủ)
        address[] memory managerAddress = new address[](timeKeys.length);
        uint256 count = timeKeys.length > 1 ? 2 : timeKeys.length;
        // Duyệt từ mới nhất đến cũ nhất
        for (uint256 i = 0; i < count; i++) {
            uint64 timeKey = timeKeys[timeKeys.length - i - 1];
            managerAddress[i] = storages[symbolKey][interval][timeKey];
        }

        return managerAddress;
    }

    // tạo nến mới
    function createCandle(
        string memory _symbol,
        string memory _interval,
        CandleRecord memory _candleRecord
    ) public {
        if (_candleRecord.isClose) {
            Interval interval = parseInterval(_interval);
            // tùy loại nến sẻ có khoảng thời gian để lưu
            bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));
            uint64 key = getTimeKey(interval, _candleRecord.openTime);
            address storageAddr = storages[symbolKey][interval][key];
            if (storageAddr == address(0)) {
                allTimekeys[symbolKey][interval].push(key);
                storageAddr = address(new CandleManagerV3());
                storages[symbolKey][interval][key] = storageAddr;
                emit ShardCreated(_symbol, _interval, key, storageAddr);
            }
            ICandleManager(storageAddr).addCandle(_candleRecord);
        }
        emit KlineCreated(
            _candleRecord.openTime,
            _candleRecord.openPrice,
            _candleRecord.highPrice,
            _candleRecord.lowPrice,
            _candleRecord.closePrice,
            _candleRecord.volume,
            _candleRecord.closeTime,
            _candleRecord.quoteAssetVolume,
            _candleRecord.numberOfTrades,
            _candleRecord.takerBuyBaseVolume,
            _candleRecord.takerBuyQuoteVolume,
            _candleRecord.isClose
        );
    }

    // get theo starttime và endtime
    function getAllAddressInRange(
        string memory _symbol,
        string memory _interval,
        uint64 startTime,
        uint64 endTime
    ) public view returns (address[] memory) {
        Interval interval = parseInterval(_interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));

        // Compute all possible timeKeys from endTime to startTime in reverse
        // tính toán khoảng thời gian cần lấy nến
        uint64[] memory timeKeys = computeTimeKeys(
            interval,
            startTime,
            endTime
        );

        address[] memory managerAddress = new address[](timeKeys.length);
        // lặp ngược lại vì nó là 12h 13h ,
        for (uint256 i = 0; i < timeKeys.length; i++) {
            address storageAddr = storages[symbolKey][interval][timeKeys[i]];
            if (storageAddr == address(0)) continue;
            managerAddress[i] = storageAddr;
        }
        // lúc fe gọi phải lấy đia chỉ cuối
        return managerAddress;
    }

    function getStep(Interval interval) internal pure returns (uint64) {
        if (interval == Interval.OneSecond) return Constance.STEP_1S;
        // 4 hours
        else if (interval == Interval.OneMinute) return Constance.STEP_1M;
        // 10 days
        else if (interval == Interval.ThreeMinutes) return Constance.STEP_3M;
        // 25 days
        else if (interval == Interval.FiveMinutes) return Constance.STEP_5M;
        // 35 days
        else if (interval == Interval.FifteenMinutes) return Constance.STEP_15M;
        // 90 days
        else if (interval == Interval.ThirtyMinutes) return Constance.STEP_30M;
        // 200 days
        else if (interval == Interval.OneHour) return Constance.STEP_1H;
        // 1 year
        else if (interval == Interval.TwoHours) return Constance.STEP_2H;
        // 2 years
        else if (interval == Interval.FourHours) return Constance.STEP_4H;
        // 4 years
        else if (interval == Interval.SixHours) return Constance.STEP_6H;
        // 6 years
        else if (interval == Interval.EightHours) return Constance.STEP_8H;
        // 8 years
        else if (interval == Interval.TwelveHours) return Constance.STEP_12H;
        // 12 years
        else if (interval == Interval.OneDay) return Constance.STEP_1D;
        // 24 years
        else if (interval == Interval.ThreeDays) return Constance.STEP_3D;
        // 72 years
        else if (interval == Interval.OneWeek) return Constance.STEP_1W;
        // 50 years
        else if (interval == Interval.OneMonth) return Constance.STEP_1MO;
        // 100 years
        else revert("Unsupported interval");
    }

    function computeTimeKeys(
        Interval interval,
        uint64 startTime,
        uint64 endTime
    ) internal pure returns (uint64[] memory keys) {
        uint64 step = getStep(interval);
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

    function getAddressManager(
        string memory _symbol,
        string memory _interval,
        uint64 _timekey
    ) public view returns (address) {
        Interval interval = parseInterval(_interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));
        uint64 key = getTimeKey(interval, _timekey);
        return storages[symbolKey][interval][key];
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
        else revert("Invalid interval string");
    }
}
