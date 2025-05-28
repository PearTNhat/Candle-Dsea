// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interface/IBTCNetFlow.sol";
import "./BTCNeflowManager.sol";
import "../../utils/Constance.sol";

// version 1 , interval lưu trong factory
contract BTCNetflowFactory {
    // symbol => interval => timeKey => storage contract
    mapping(Interval => mapping(uint64 => address)) public storages;
    // lưu các timekeys của 1 interval đẻ biết đã tạo bao nhiêu contract
    mapping(Interval => uint64[]) public allTimekeys;

    event NetFlowStorageCreated(
        Interval indexed interval,
        uint64 indexed timeKey,
        address storageAddress
    );
    event BTCNetFlowCreated(
        Interval indexed interval,
        uint64 indexed timeKey,
        address indexed storageAddr,
        uint256 inflow,
        uint256 outflow,
        uint256 price,
        uint256 volume,
        uint256 marketCap,
        uint256 aum
    );

    function createBTCNetflow(
        string memory _interval,
        BTCNetFlowStruct calldata data
    ) external {
        Interval interval = parseInterval(_interval);
        uint64 timeKey = data.timestamp;
        address storageAddr = storages[interval][timeKey];

        if (storageAddr == address(0)) {
            BTCNetFlowManager manager = new BTCNetFlowManager();
            storageAddr = address(manager);
            storages[interval][timeKey] = storageAddr;
            allTimekeys[interval].push(timeKey);

            emit NetFlowStorageCreated(interval, timeKey, storageAddr);
        }
        emit BTCNetFlowCreated(
            interval,
            timeKey,
            storageAddr,
            data.inflow,
            data.outflow,
            data.price,
            data.volume,
            data.marketCap,
            data.aum
        );

        IBTCNetFlow(storageAddr).addNetFlow(data);
    }

    function getNetFlows(Interval interval, uint64 timeKey)
        external
        view
        returns (BTCNetFlowStruct[] memory)
    {
        address storageAddr = storages[interval][timeKey];
        require(storageAddr != address(0), "Storage does not exist");

        return IBTCNetFlow(storageAddr).getNetFlows();
    }

    function getNetFlowCount(Interval interval, uint64 timeKey)
        external
        view
        returns (uint256)
    {
        address storageAddr = storages[interval][timeKey];
        require(storageAddr != address(0), "Storage does not exist");

        return IBTCNetFlow(storageAddr).getNetFlowCount();
    }

    function initBTCNetflow(string memory _interval, uint256 limit)
        public
        view
        returns (BTCNetFlowStruct[] memory result)
    {
        if (limit == 0) {
            limit = 300;
        }
        Interval interval = parseInterval(_interval);
        uint64[] storage timeKeys = allTimekeys[interval];

        BTCNetFlowStruct[] memory temp = new BTCNetFlowStruct[](limit);
        uint256 count = 0;

        // Duyệt từ cuối mảng về đầu (mới nhất đến cũ hơn)
        for (uint256 i = timeKeys.length; i > 0; i--) {
            if (count >= limit) break;

            uint64 timeKey = timeKeys[i - 1];
            address storageAddr = storages[interval][timeKey];
            if (storageAddr != address(0)) {
                BTCNetFlowStruct[] memory records = IBTCNetFlow(storageAddr)
                    .getNetFlows();

                for (uint256 j = records.length; j > 0; j--) {
                    if (count >= limit) break;
                    temp[count++] = records[j - 1]; // mới nhất trong block nến
                }
            }
        }

        result = new BTCNetFlowStruct[](count);
        for (uint256 i = count; i > 0; i--) {
            result[count - i] = temp[i - 1];
        }
    }

    function getAllTimekeys(Interval interval)
        external
        view
        returns (uint64[] memory)
    {
        return allTimekeys[interval];
    }

    function getTimeKey(Interval interval, uint64 timestamp)
        internal
        pure
        returns (uint64)
    {
        if (interval == Interval.OneHour)
            return (timestamp / Constance.STEP_1H) * Constance.STEP_1H;
        // 1 year
        else if (interval == Interval.OneDay)
            return (timestamp / Constance.STEP_1D) * Constance.STEP_1D;
        // 24 years
        else if (interval == Interval.OneMonth)
            return (timestamp / Constance.STEP_1MO) * Constance.STEP_1MO;
        // 100 years
        else revert("Unsupported interval");
    }

    function parseInterval(string memory s) internal pure returns (Interval) {
        bytes32 h = keccak256(abi.encodePacked(s));
        if (h == Constance.INTERVAL_1H) return Interval.OneHour;
        else if (h == Constance.INTERVAL_1D) return Interval.OneDay;
        else if (h == Constance.INTERVAL_1MO) return Interval.OneMonth;
        else revert("Invalid interval string");
    }
}
