// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KlineIntervalFactory.sol";
import "../../interface/IKlineIntervalFactory.sol";
import "../../utils/Constance.sol";

contract KlineFactoryV2 {
    // symbol -> interval -> address
    mapping(bytes32 => mapping(Interval => address)) public factories;

    event FactoryCreated(
        string indexed symbol,
        string indexed interval,
        address factoryAddress
    );

    // Hàm để lấy hoặc tạo mới một KlineInterValFactory cho symbol và interval
    function _getOrCreateFactory(string memory symbol, string memory interval)
        internal
        returns (address)
    {
        Interval intervalEnum = parseInterval(interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(symbol));
        address factoryAddr = factories[symbolKey][intervalEnum];
        if (factoryAddr == address(0)) {
            factoryAddr = address(new KlineInterValFactory());
            factories[symbolKey][intervalEnum] = factoryAddr;
            emit FactoryCreated(symbol, interval, factoryAddr);
        }
        return factoryAddr;
    }

    // Thêm một KlineRecord
    function addKline(
        string memory symbol,
        string memory interval,
        KlineRecord memory record
    ) public {
        address factoryAddr = _getOrCreateFactory(symbol, interval);
        Interval intervalEnum = parseInterval(interval);
        IKlineIntervalFactory(factoryAddr).addKline(record, intervalEnum);
    }

    // Lấy số lượng Kline trong một time key
    function getLengthKline(
        string memory symbol,
        string memory interval,
        uint64 timestamp
    ) public view returns (uint256) {
        Interval intervalEnum = parseInterval(interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(symbol));
        address factoryAddr = factories[symbolKey][intervalEnum];
        require(
            factoryAddr != address(0),
            "Factory not found for symbol and interval"
        );
        return
            IKlineIntervalFactory(factoryAddr).getLengthKline(
                intervalEnum,
                timestamp
            );
    }

    // Lấy tất cả Kline trong một time key
    function getAllKlineInTime(
        string memory symbol,
        string memory interval,
        uint64 timestamp
    ) public view returns (KlineResponse[] memory) {
        Interval intervalEnum = parseInterval(interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(symbol));
        address factoryAddr = factories[symbolKey][intervalEnum];
        require(
            factoryAddr != address(0),
            "Factory not found for symbol and interval"
        );
        return
            IKlineIntervalFactory(factoryAddr).getAllklineInTime(
                intervalEnum,
                timestamp
            );
    }

    // Lấy tất cả Kline trong khoảng thời gian từ startTime đến endTime
    function getAllRecords(
        string memory symbol,
        string memory interval,
        uint64 startTime,
        uint64 endTime,
        uint256 limit
    ) public view returns (KlineResponse[] memory) {
        Interval intervalEnum = parseInterval(interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(symbol));
        address factoryAddr = factories[symbolKey][intervalEnum];
        require(
            factoryAddr != address(0),
            "Factory not found for symbol and interval"
        );
        return
            IKlineIntervalFactory(factoryAddr).getAllRecords(
                intervalEnum,
                startTime,
                endTime,
                limit
            );
    }

    // Lấy tất cả time keys cho một interval
    function getAllTimeKeys(string memory symbol, string memory interval)
        public
        view
        returns (uint64[] memory)
    {
        Interval intervalEnum = parseInterval(interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(symbol));
        address factoryAddr = factories[symbolKey][intervalEnum];
        require(
            factoryAddr != address(0),
            "Factory not found for symbol and interval"
        );
        return IKlineIntervalFactory(factoryAddr).getAllTimeKeys(intervalEnum);
    }

    // Lấy số lượng time keys cho một interval
    function getLengthTimeKeys(string memory symbol, string memory interval)
        public
        view
        returns (uint256)
    {
        Interval intervalEnum = parseInterval(interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(symbol));
        address factoryAddr = factories[symbolKey][intervalEnum];
        require(
            factoryAddr != address(0),
            "Factory not found for symbol and interval"
        );
        return
            IKlineIntervalFactory(factoryAddr).getLengthTimeKeys(intervalEnum);
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
