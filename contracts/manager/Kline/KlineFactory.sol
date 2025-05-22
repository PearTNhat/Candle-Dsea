// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseKline.sol";
import "../../utils/StringUtils.sol";
import "../../interface/IKlineManager.sol";
import "hardhat/console.sol";

contract KlineFactory {
    // time trong 1h -> interval -> data 
    mapping(bytes32 => mapping(Interval => mapping(uint64 => address))) public storages;

    event KlineContractCreated(uint key, address contractAddress);
    event ShardCreated(
        string symbol,
        string interval,
        uint64 timeKey,
        address storageAddress
    );

    // lưu trong 1 h
    // sử lý lại interval có chỉ đc giới hạn từng đó thôi
      // Calculate the shard key (hourly) for all intervals
    function getTimeKey(Interval, uint64 timestamp)
        public
        pure
        returns (uint64)
    {
        return (timestamp / (60 * 60 * 1000)) * (60 * 60 * 1000);
    }

   function addKline(KlineRecord memory record, uint64 timestamp) public {
        // parse interval
        Interval interval = parseInterval(record.i);
        bytes32 symbolKey = keccak256(abi.encodePacked(record.s));
        // uint64 key = getTimeKey(interval, uint64(block.timestamp * 1000));
        //test
        uint64 key = getTimeKey(interval, uint64(timestamp));

        address storageAddr = storages[symbolKey][interval][key];
        if (storageAddr == address(0)) {
            console.log("Creating new shard at", key);
            storageAddr = address(new BaseKline());
            storages[symbolKey][interval][key] = storageAddr;
            emit ShardCreated(record.s, record.i, key, storageAddr);
        }

        IKlineManager(storageAddr).recordKline(record);
    }

    function getLengthKline(string memory _symbol, string memory _interval, uint64 timestime) public view returns (uint256) {
        Interval interval = parseInterval(_interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));
        uint64 key = getTimeKey(interval, timestime);
        address storageAddr = storages[symbolKey][interval][key];
        require(storageAddr != address(0), "Address is not found");
        return IKlineManager(storageAddr).getLength();
    }
    function getAllklineInTime (string memory _symbol, string memory _interval, uint64 timestime) public view returns (KlineResponse[] memory) {
        Interval interval = parseInterval(_interval);
        bytes32 symbolKey = keccak256(abi.encodePacked(_symbol));
        uint64 key = getTimeKey(interval, timestime);

        address storageAddr = storages[symbolKey][interval][key];
        return IKlineManager(storageAddr).getAllKline();
    }
    function parseInterval(string memory s) public pure returns (Interval) {
        bytes32 h = keccak256(abi.encodePacked(s));
        if (h == keccak256("1s")) return Interval.OneSecond;
        if (h == keccak256("1m")) return Interval.OneMinute;
        if (h == keccak256("3m")) return Interval.ThreeMinutes;
        if (h == keccak256("5m")) return Interval.FiveMinutes;
        if (h == keccak256("15m")) return Interval.FifteenMinutes;
        if (h == keccak256("30m")) return Interval.ThirtyMinutes;
        if (h == keccak256("1h")) return Interval.OneHour;
        if (h == keccak256("2h")) return Interval.TwoHours;
        if (h == keccak256("4h")) return Interval.FourHours;
        if (h == keccak256("6h")) return Interval.SixHours;
        if (h == keccak256("8h")) return Interval.EightHours;
        if (h == keccak256("12h")) return Interval.TwelveHours;
        if (h == keccak256("1d")) return Interval.OneDay;
        if (h == keccak256("3d")) return Interval.ThreeDays;
        if (h == keccak256("1w")) return Interval.OneWeek;
        if (h == keccak256("1M")) return Interval.OneMonth;
        revert("Invalid interval string");
    }

}
