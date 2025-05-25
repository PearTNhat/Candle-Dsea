// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseKline.sol";
import "../../interface/IKlineManager.sol";
import "../../utils/Constance.sol";
import "../../interface/IKlineIntervalFactory.sol";
import "hardhat/console.sol";

contract KlineInterValFactory is IKlineIntervalFactory{
    // interval -> key -> address
    mapping(Interval => mapping(uint64 => address)) public storages;
    // lưu các timekeys của 1 interval đẻ biết đã tạo bao nhiêu contract
    mapping(Interval => uint64[]) public allTimekeys;

    // lưu trong 1 h
    function getTimeKey(Interval, uint64 timestamp)
        internal
        pure
        returns (uint64)
    {
        return (timestamp /Constance.STEP_1S) * (Constance.STEP_1S);
    }

    function addKline(KlineRecord memory record, Interval interval) public {
        //test
        uint64 key = getTimeKey(interval, record.t);
        address storageAddr = storages[interval][key];
        if (storageAddr == address(0)) {
            allTimekeys[interval].push(key);
            storageAddr = address(new BaseKline());
            storages[interval][key] = storageAddr;
        }
        IKlineManager(storageAddr).recordKline(record);
    }

    function getLengthKline(Interval interval, uint64 timestamp)
        public
        view
        returns (uint256)
    {
        uint64 key = getTimeKey(interval, timestamp);
        address storageAddr = storages[interval][key];
        require(storageAddr != address(0), "Address is not found");
        return IKlineManager(storageAddr).getLength();
    }

    function getAllklineInTime(Interval interval, uint64 timestime)
        public
        view
        returns (KlineResponse[] memory)
    {
        uint64 key = getTimeKey(interval, timestime);
        address storageAddr = storages[interval][key];
        require(storageAddr != address(0), "Address is not found");
        return IKlineManager(storageAddr).getAllKline();
    }

    // get theo starttime và endtime
    function getAllRecords(
        Interval interval,
        uint64 startTime,
        uint64 endTime,
        uint256 limit
    ) public view returns (KlineResponse[] memory result) {
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
            address storageAddr = storages[interval][timeKeys[i - 1]];
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
        uint64 step = Constance.STEP_1S; // vì là lưu trong 4h, nếu trên kia lưu giờ khác thì đổi lại
        uint64 from = getTimeKey(interval, startTime);
        uint64 to = getTimeKey(interval, endTime);
        uint256 count;
        // ví dụ nến 1s , lưu trong 1h
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

    function getAllTimeKeys(Interval interval)
        public
        view
        returns (uint64[] memory)
    {
        return allTimekeys[interval];
    }

    function getLengthTimeKeys(Interval interval)
        public
        view
        returns (uint256)
    {
        return allTimekeys[interval].length;
    }
}
