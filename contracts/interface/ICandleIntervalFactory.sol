// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../struct/CandleStruct.sol";

interface ICandleIntervalFactory {
    function initCandle(
        string memory _interval,
        uint256 limit
    ) external view returns (CandleRecord[] memory);

    function createCandle(
        string memory _interval,
        CandleRecord memory _candleRecord
    ) external;

    function getAllRecords(
        string memory _interval,
        uint64 startTime,
        uint64 endTime,
        uint256 limit
    ) external view returns (CandleRecord[] memory);

    function getAllCandlesInTime(
        string memory _interval,
        uint64 _timekey
    ) external view returns (CandleRecord[] memory);

    function getAllTimeKeys(string memory _interval)
        external
        view
        returns (uint64[] memory);

    function getLengthTimeKeys(string memory _interval)
        external
        view
        returns (uint256);
}
