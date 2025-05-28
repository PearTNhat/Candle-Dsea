// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "./CandleManager.sol";
// import "../../interface/ICandleManager.sol";
// import "../../utils/Constance.sol";
// import "../../interface/ICandleIntervalFactory.sol";
// import "hardhat/console.sol";

// contract CandleIntervalFactory {
//     // interval => timeKey => storage contract
//     mapping(Interval => mapping(uint64 => address)) public storages;
//     // lưu các timekeys của 1 interval đẻ biết đã tạo bao nhiêu contract
//     mapping(Interval => uint64[]) public allTimekeys;
//     event ShardCreated(
//         string indexed symbol,
//         string indexed interval,
//         uint64 indexed timeKey,
//         address storageAddress
//     );

//     function getTimeKey(Interval interval, uint64 timestamp)
//         internal
//         pure
//         returns (uint64)
//     {
//         if (interval == Interval.OneSecond)
//             return (timestamp / Constance.STEP_1S) * Constance.STEP_1S;
//         // 4 hours
//         else if (interval == Interval.OneMinute)
//             return (timestamp / Constance.STEP_1M) * Constance.STEP_1M;
//         // 10 days
//         else if (interval == Interval.ThreeMinutes)
//             return (timestamp / Constance.STEP_3M) * Constance.STEP_3M;
//         // 25 days
//         else if (interval == Interval.FiveMinutes)
//             return (timestamp / Constance.STEP_5M) * Constance.STEP_5M;
//         // 35 days
//         else if (interval == Interval.FifteenMinutes)
//             return (timestamp / Constance.STEP_15M) * Constance.STEP_15M;
//         // 90 days
//         else if (interval == Interval.ThirtyMinutes)
//             return (timestamp / Constance.STEP_30M) * Constance.STEP_30M;
//         // 200 days
//         else if (interval == Interval.OneHour)
//             return (timestamp / Constance.STEP_1H) * Constance.STEP_1H;
//         // 1 year
//         else if (interval == Interval.TwoHours)
//             return (timestamp / Constance.STEP_2H) * Constance.STEP_2H;
//         // 2 years
//         else if (interval == Interval.FourHours)
//             return (timestamp / Constance.STEP_4H) * Constance.STEP_4H;
//         // 4 years
//         else if (interval == Interval.SixHours)
//             return (timestamp / Constance.STEP_6H) * Constance.STEP_6H;
//         // 6 years
//         else if (interval == Interval.EightHours)
//             return (timestamp / Constance.STEP_8H) * Constance.STEP_8H;
//         // 8 years
//         else if (interval == Interval.TwelveHours)
//             return (timestamp / Constance.STEP_12H) * Constance.STEP_12H;
//         // 12 years
//         else if (interval == Interval.OneDay)
//             return (timestamp / Constance.STEP_1D) * Constance.STEP_1D;
//         // 24 years
//         else if (interval == Interval.ThreeDays)
//             return (timestamp / Constance.STEP_3D) * Constance.STEP_3D;
//         // 72 years
//         else if (interval == Interval.OneWeek)
//             return (timestamp / Constance.STEP_1W) * Constance.STEP_1W;
//         // 50 years
//         else if (interval == Interval.OneMonth)
//             return (timestamp / Constance.STEP_1MO) * Constance.STEP_1MO;
//         // 100 years
//         else revert("Unsupported interval");
//     }


//     function initCandle(Interval interval, uint256 limit)
//         public
//         view
//         returns (CandleRecord[] memory result)
//     {
//         if (limit == 0) {
//             limit = 300;
//         }

//         uint64[] storage timeKeys = allTimekeys[interval];
//         CandleRecord[] memory temp = new CandleRecord[](limit);
//         uint256 count = 0;

//         for (uint256 i = timeKeys.length; i > 0 && count < limit; i--) {
//             uint64 timeKey = timeKeys[i - 1];
//             address storageAddr = storages[interval][timeKey];
//             if (storageAddr != address(0)) {
//                 CandleRecord[] memory records = ICandleManager(storageAddr)
//                     .getCandles();
//                 uint256 rLen = records.length;

//                 for (uint256 j = rLen; j > 0 && count < limit; j--) {
//                     temp[count++] = records[j - 1];
//                 }
//             }
//         }

//         result = new CandleRecord[](count);
//         for (uint256 i = 0; i < count; i++) {
//             result[i] = temp[count - 1 - i]; // đảo ngược để trả về cũ → mới
//         }
//     }

//     // tạo nến mới
//     function createCandle(Interval interval, CandleRecord memory _candleRecord)
//         public
//     {
//         // tùy loại nến sẻ có khoảng thời gian để lưu
//         uint64 key = getTimeKey(interval, _candleRecord.openTime);
//         address storageAddr = storages[interval][key];
//         if (storageAddr == address(0)) {
//             allTimekeys[interval].push(key);
//             storageAddr = address(new CandleManager());
//             storages[interval][key] = storageAddr;
//         }
//         ICandleManager(storageAddr).addCandle(_candleRecord);
//     }

//     // get theo starttime và endtime
//     function getAllRecords(
//         Interval interval,
//         uint64 startTime,
//         uint64 endTime,
//         uint256 limit
//     ) public view returns (CandleRecord[] memory result) {
//         // Compute all possible timeKeys from endTime to startTime in reverse
//         // tính toán khoảng thời gian cần lấy nến
//         uint64[] memory timeKeys = computeTimeKeys(
//             interval,
//             startTime,
//             endTime
//         );

//         uint256 count;
//         CandleRecord[] memory temp = new CandleRecord[](limit);
//         // lặp ngược lại vì nó là 12h 13h ,
//         for (uint256 i = timeKeys.length; i > 0; i--) {
//             //  console.log("Time key",timeKeys[i-1]);
//             address storageAddr = storages[interval][timeKeys[i - 1]];
//             if (storageAddr == address(0)) continue;
//             CandleRecord[] memory records = ICandleManager(storageAddr)
//                 .getCandles();
//             for (uint256 j = records.length; j > 0; j--) {
//                 CandleRecord memory c = records[j - 1];
//                 if (c.openTime >= startTime && c.closeTime <= endTime) {
//                     temp[count++] = c;
//                     if (count == limit) break;
//                 }
//             }
//             if (count == limit) break;
//         }

//         // Copy to exact size array
//         result = new CandleRecord[](count);
//         for (uint256 i = count; i > 0; i--) {
//             result[count - i] = temp[i - 1];
//         }
//     }

//     function getLengthData(Interval interval, uint64 _timekey)
//         public
//         view 
//         returns (uint256)
//     {
//         address _address = storages[interval][_timekey];
//         require(_address != address(0),"address not found");
//         return ICandleManager(_address).candleCount();
//     }

//     function getStep(Interval interval) internal pure returns (uint64) {
//         if (interval == Interval.OneSecond) return Constance.STEP_1S;
//         // 4 hours
//         else if (interval == Interval.OneMinute) return Constance.STEP_1M;
//         // 10 days
//         else if (interval == Interval.ThreeMinutes) return Constance.STEP_3M;
//         // 25 days
//         else if (interval == Interval.FiveMinutes) return Constance.STEP_5M;
//         // 35 days
//         else if (interval == Interval.FifteenMinutes) return Constance.STEP_15M;
//         // 90 days
//         else if (interval == Interval.ThirtyMinutes) return Constance.STEP_30M;
//         // 200 days
//         else if (interval == Interval.OneHour) return Constance.STEP_1H;
//         // 1 year
//         else if (interval == Interval.TwoHours) return Constance.STEP_2H;
//         // 2 years
//         else if (interval == Interval.FourHours) return Constance.STEP_4H;
//         // 4 years
//         else if (interval == Interval.SixHours) return Constance.STEP_6H;
//         // 6 years
//         else if (interval == Interval.EightHours) return Constance.STEP_8H;
//         // 8 years
//         else if (interval == Interval.TwelveHours) return Constance.STEP_12H;
//         // 12 years
//         else if (interval == Interval.OneDay) return Constance.STEP_1D;
//         // 24 years
//         else if (interval == Interval.ThreeDays) return Constance.STEP_3D;
//         // 72 years
//         else if (interval == Interval.OneWeek) return Constance.STEP_1W;
//         // 50 years
//         else if (interval == Interval.OneMonth) return Constance.STEP_1MO;
//         // 100 years
//         else revert("Unsupported interval");
//     }

//     function computeTimeKeys(
//         Interval interval,
//         uint64 startTime,
//         uint64 endTime
//     ) internal pure returns (uint64[] memory keys) {
//         uint64 step = getStep(interval);
//         uint64 from = getTimeKey(interval, startTime);
//         uint64 to = getTimeKey(interval, endTime);
//         uint256 count;
//         // ví dụ nến 1s
//         // TH: 1h -> 2h
//         if (startTime == from && endTime == to) {
//             count = (to - from) / step;
//         } else {
//             // TH: 1h -> 2h30: 1h-2h , 1h30 -> 2h30: 1h-2h, 1h30 -> 1h45
//             count = ((to - from) / step) + 1;
//         }
//         keys = new uint64[](count);

//         for (uint256 i = 0; i < count; i++) {
//             keys[i] = from + uint64(i * step);
//         }
//     }

//     function getAllCandlesInTime(Interval interval, uint64 _timekey)
//         public
//         view
//         returns (CandleRecord[] memory)
//     {
//         uint64 key = getTimeKey(interval, _timekey);
//         address _address = storages[interval][key];
//         return ICandleManager(address(_address)).getCandles();
//     }

//     function getAllTimeKeys(Interval interval)
//         public
//         view
//         returns (uint64[] memory)
//     {
//         return allTimekeys[interval];
//     }

//     function getLengthTimeKeys(Interval interval)
//         public
//         view
//         returns (uint256)
//     {
//         return allTimekeys[interval].length;
//     }
// }
