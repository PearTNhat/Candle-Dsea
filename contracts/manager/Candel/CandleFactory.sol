// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CandleManager.sol";
import "../../interface/ICandleManager.sol";
import "hardhat/console.sol";

contract CandleFactory {
    // symbol => interval => timeKey => storage contract
    mapping(bytes32 => mapping(Interval => mapping(uint64 => address)))
        public storages;
    // lưu các timekeys của 1 interval đẻ biết đã tạo bao nhiêu contract
    mapping(bytes32 => mapping(Interval => uint64[])) public allTimekeys;
    event ShardCreated(
        string symbol,
        string interval,
        uint64 timeKey,
        address storageAddress
    );
    event CandleCreated(
        uint64 openTime,
        string openPrice,
        string highPrice,
        string lowPrice,
        string closePrice,
        string volume,
        uint64 closeTime,
        string quoteAssetVolume,
        uint32 numberOfTrades,
        string takerBuyBaseVolume,
        string takerBuyQuoteVolume
    );

    function getTimeKey(Interval interval, uint64 timestamp)
        internal
        pure
        returns (uint64)
    {
        if (interval == Interval.OneSecond)
            return (timestamp / (60 * 60 * 1000)) * (60 * 60 * 1000); // hourly
        if (
            interval == Interval.OneMinute ||
            interval == Interval.ThreeMinutes ||
            interval == Interval.FiveMinutes
        ) return (timestamp / (24 * 60 * 60 * 1000)) * (24 * 60 * 60 * 1000); // daily
        if (
            interval == Interval.FifteenMinutes ||
            interval == Interval.ThirtyMinutes ||
            interval == Interval.OneHour ||
            interval == Interval.TwoHours
        )
            return
                (timestamp / (7 * 24 * 60 * 60 * 1000)) *
                (7 * 24 * 60 * 60 * 1000); // weekly
        if (
            interval == Interval.FourHours ||
            interval == Interval.SixHours ||
            interval == Interval.EightHours ||
            interval == Interval.TwelveHours
        )
            return
                (timestamp / (30 * 24 * 60 * 60 * 1000)) *
                (30 * 24 * 60 * 60 * 1000); // monthly (~30 days)
        if (interval == Interval.OneDay || interval == Interval.ThreeDays)
            return
                (timestamp / (90 * 24 * 60 * 60 * 1000)) *
                (90 * 24 * 60 * 60 * 1000); // quarterly (~90 days)
        if (interval == Interval.OneWeek || interval == Interval.OneMonth)
            return
                (timestamp / (4 *365 * 24 * 60 * 60 * 1000)) *
                (4 * 365 * 24 * 60 * 60 * 1000); // yearly

        revert("Unsupported interval");
    }

    // function initCandle(
    //     string memory _symbol,
    //     string memory _interval,
    //     uint256 limit
    // ) public view returns (CandleRecord[] memory result) {
    //     if (limit == 0) {
    //         limit = 300;
    //     }
    //     Interval interval = parseInterval(_interval);
    //     bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));
    //     uint64 nowTime = uint64(block.timestamp * 1000);
    //     uint64 currentTimeKey = getTimeKey(interval, nowTime);
    //     uint64 step = getStep(interval);
    //     CandleRecord[] memory temp = new CandleRecord[](limit);
    //     uint256 count = 0;

    //     while (true) {
    //         address storageAddr = storages[symbolKey][interval][currentTimeKey];
    //         if (storageAddr != address(0)) {
    //             CandleRecord[] memory records = ICandleManager(storageAddr)
    //                 .getCandles();

    //             for (uint256 j = records.length; j > 0; j--) {
    //                 if (count == limit) break;
    //                 temp[count++] = records[j - 1];
    //             }
    //         } else {
    //             break;
    //         }
    //         if (count >= limit) break;
    //         if (currentTimeKey < step) break;
    //         currentTimeKey -= step;
    //     }

    //     result = new CandleRecord[](count);
    //     for (uint256 i = 0; i < count; i++) {
    //         result[i] = temp[i];
    //     }
    // }
    function initCandle(
        string memory _symbol,
        string memory _interval,
        uint256 limit
    ) public view returns (CandleRecord[] memory result) {
        if (limit == 0) {
            limit = 300;
        }

        Interval interval = parseInterval(_interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));
        uint64[] storage timeKeys = allTimekeys[symbolKey][interval];

        CandleRecord[] memory temp = new CandleRecord[](limit);
        uint256 count = 0;

        // Duyệt từ cuối mảng về đầu (mới nhất đến cũ hơn)
        for (uint256 i = timeKeys.length; i > 0; i--) {
            if (count >= limit) break;

            uint64 timeKey = timeKeys[i - 1];
            address storageAddr = storages[symbolKey][interval][timeKey];
            if (storageAddr != address(0)) {
                CandleRecord[] memory records = ICandleManager(storageAddr)
                    .getCandles();

                for (uint256 j = records.length; j > 0; j--) {
                    if (count >= limit) break;
                    temp[count++] = records[j - 1]; // mới nhất trong block nến
                }
            }
        }

        result = new CandleRecord[](count);
        for (uint256 i = count; i > 0; i--) {
            result[count - i] = temp[i - 1];
        }
    }

    // tạo nến mới
    function createCandle(
        string memory _symbol,
        string memory _interval,
        CandleRecord memory _candleRecord
    ) public {
        Interval interval = parseInterval(_interval);
        // tùy loại nến sẻ có khoảng thời gian để lưu
        bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));
        uint64 key = getTimeKey(interval, _candleRecord.openTime);
        address storageAddr = storages[symbolKey][interval][key];
        if (storageAddr == address(0)) {
            console.log("Create new addrresss");
            allTimekeys[symbolKey][interval].push(key);
            storageAddr = address(new CandleManager());
            storages[symbolKey][interval][key] = storageAddr;
            emit ShardCreated(_symbol, _interval, key, storageAddr);
        }
        emit CandleCreated(
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
            _candleRecord.takerBuyQuoteVolume
        );
        ICandleManager(storageAddr).addCandle(_candleRecord);
    }

    // get theo starttime và endtime
    function getAllRecords(
        string memory _symbol,
        string memory _interval,
        uint64 startTime,
        uint64 endTime,
        uint256 limit
    ) public view returns (CandleRecord[] memory result) {
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
        CandleRecord[] memory temp = new CandleRecord[](limit);
        // lặp ngược lại vì nó là 12h 13h ,
        for (uint256 i = 0; i < timeKeys.length; i++) {
            address storageAddr = storages[symbolKey][interval][timeKeys[i]];
            if (storageAddr == address(0)) continue;
            // cần tối ưu đoạn này nếu k tối ưu được time key
            console.log("Time: ", timeKeys[i]);
            CandleRecord[] memory records = ICandleManager(storageAddr)
                .getCandles();
            for (uint256 j = records.length; j > 0; j--) {
                CandleRecord memory c = records[j - 1];
                if (c.openTime < startTime) continue;
                if (c.openTime > endTime) continue;
                temp[count++] = c;
                console.log("elem time:", c.openTime);
                if (count == limit) break;
            }
            if (count == limit) break;
        }

        // Copy to exact size array
        result = new CandleRecord[](count);
        for (uint256 i = count; i > 0; i--) {
            result[count - i] = temp[i - 1];
        }
    }

    function getStep(Interval interval) internal pure returns (uint64) {
        if (interval == Interval.OneSecond) 
        return 60 * 60 * 1000;
        else if (
            interval == Interval.OneMinute ||
            interval == Interval.ThreeMinutes ||
            interval == Interval.FiveMinutes
        ) return 24 * 60 * 60 * 1000;
        else if (
            interval == Interval.FifteenMinutes ||
            interval == Interval.ThirtyMinutes ||
            interval == Interval.OneHour ||
            interval == Interval.TwoHours
        ) return 7 * 24 * 60 * 60 * 1000;
        else if (
            interval == Interval.FourHours ||
            interval == Interval.SixHours ||
            interval == Interval.EightHours ||
            interval == Interval.TwelveHours
        ) return 30 * 24 * 60 * 60 * 1000;
        else if (interval == Interval.OneDay || interval == Interval.ThreeDays)
            return 90 * 24 * 60 * 60 * 1000;
        else if (interval == Interval.OneWeek || interval == Interval.OneMonth)
            return 4 * 365 * 24 * 60 * 60 * 1000;
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

        uint256 count = ((to - from) / step) + 1;
        keys = new uint64[](count);

        for (uint256 i = 0; i < count; i++) {
            keys[i] = from + uint64(i * step);
        }
    }

    // get tất cả nến trong 1 móc thời gian
    function getAllCandlesInTime(
        string memory _symbol,
        string memory _interval,
        uint64 _timekey
    ) public view returns (CandleRecord[] memory) {
        Interval interval = parseInterval(_interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));
        uint64 key = getTimeKey(interval, _timekey);
        address _address = storages[symbolKey][interval][key];
        return ICandleManager(address(_address)).getAllCandles();
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

        if (h == keccak256("1s")) return Interval.OneSecond;
        else if (h == keccak256("1m")) return Interval.OneMinute;
        else if (h == keccak256("3m")) return Interval.ThreeMinutes;
        else if (h == keccak256("5m")) return Interval.FiveMinutes;
        else if (h == keccak256("15m")) return Interval.FifteenMinutes;
        else if (h == keccak256("30m")) return Interval.ThirtyMinutes;
        else if (h == keccak256("1h")) return Interval.OneHour;
        else if (h == keccak256("2h")) return Interval.TwoHours;
        else if (h == keccak256("4h")) return Interval.FourHours;
        else if (h == keccak256("6h")) return Interval.SixHours;
        else if (h == keccak256("8h")) return Interval.EightHours;
        else if (h == keccak256("12h")) return Interval.TwelveHours;
        else if (h == keccak256("1d")) return Interval.OneDay;
        else if (h == keccak256("3d")) return Interval.ThreeDays;
        else if (h == keccak256("1w")) return Interval.OneWeek;
        else if (h == keccak256("1M")) return Interval.OneMonth;
        else revert("Invalid interval string");
    }
}
