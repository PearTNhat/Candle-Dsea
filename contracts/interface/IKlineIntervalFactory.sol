// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../struct/KlineStruct.sol";

interface IKlineIntervalFactory {
    function addKline(KlineRecord memory record, Interval interval) external;

    function getLengthKline(Interval interval, uint64 timestamp)
        external
        view
        returns (uint256);

    function getAllklineInTime(Interval interval, uint64 timestamp)
        external
        view
        returns (KlineResponse[] memory);

    function getAllRecords(
        Interval interval,
        uint64 startTime,
        uint64 endTime,
        uint256 limit
    ) external
        view
        returns (KlineResponse[] memory);

    function getAllTimeKeys(Interval interval)
        external
        view
        returns (uint64[] memory);

    function getLengthTimeKeys(Interval interval)
        external
        view
        returns (uint256);
}
