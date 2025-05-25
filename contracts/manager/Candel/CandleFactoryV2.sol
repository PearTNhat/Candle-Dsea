// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./CandleManager.sol";
import "./CandleInervalFactory.sol";
import "../../interface/ICandleIntervalFactory.sol";
// interval lưu ở smc intervalFactory
contract CandleFactoryV2 {
    // symbol => interval => CandleInterValFactory
    mapping(bytes32 => mapping(Interval => address)) public factories;
    event IntervalFactoryCreated(
        bytes32 indexed symbol,
        Interval indexed interval,
        address factoryAddress
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
    function _getSymbolKey(string memory symbol)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(symbol));
    }

    function _getOrCreateIntervalFactory(
        string memory symbol,
        Interval interval
    ) internal returns (address) {
        bytes32 symbolKey = _getSymbolKey(symbol);
        address factory = factories[symbolKey][interval];
        if (factory == address(0)) {
            CandleIntervalFactory newFactory = new CandleIntervalFactory();
            factory = address(newFactory);
            factories[symbolKey][interval] = factory;
            emit IntervalFactoryCreated(symbolKey, interval, factory);
        }
        return factory;
    }

    function createCandle(
        string memory symbol,
        string memory intervalStr,
        CandleRecord memory record
    ) public {
        Interval interval = parseInterval(intervalStr);
        address factory = _getOrCreateIntervalFactory(symbol, interval);
        CandleIntervalFactory(factory).createCandle(interval, record);
        emit CandleCreated(
            record.openTime,
            record.openPrice,
            record.highPrice,
            record.lowPrice,
            record.closePrice,
            record.volume,
            record.closeTime,
            record.quoteAssetVolume,
            record.numberOfTrades,
            record.takerBuyBaseVolume,
            record.takerBuyQuoteVolume
        );
    }

    function getLatestCandles(
        string memory symbol,
        string memory intervalStr,
        uint256 limit
    ) public view returns (CandleRecord[] memory) {
        Interval interval = parseInterval(intervalStr);
        address factory = factories[_getSymbolKey(symbol)][interval];
        require(factory != address(0), "Factory not found");
        return CandleIntervalFactory(factory).initCandle(interval, limit);
    }

    function getCandlesInRange(
        string memory symbol,
        string memory intervalStr,
        uint64 startTime,
        uint64 endTime,
        uint256 limit
    ) public view returns (CandleRecord[] memory) {
        Interval interval = parseInterval(intervalStr);
        address factory = factories[_getSymbolKey(symbol)][interval];
        require(factory != address(0), "Factory not found");
        return
            CandleIntervalFactory(factory).getAllRecords(
                interval,
                startTime,
                endTime,
                limit
            );
    }

    function getTimeKeys(string memory symbol, string memory intervalStr)
        public
        view
        returns (uint64[] memory)
    {
        Interval interval = parseInterval(intervalStr);
        address factory = factories[_getSymbolKey(symbol)][interval];
        require(factory != address(0), "Factory not found");
        return CandleIntervalFactory(factory).getAllTimeKeys(interval);
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
