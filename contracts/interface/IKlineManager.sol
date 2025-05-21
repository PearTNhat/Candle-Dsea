// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../struct/KlineStruct.sol";
interface IKlineManager {
    event AddKlineRecord(uint256 timestamp, string symbol, string open, string close);
    
    function recordKline(KlineRecord calldata kline) external;
    function getKline(uint256 timestamp) external view returns (KlineResponse memory);
    // function getLastKline() external view returns (CandleResponse memory);
    function getAllKline() external  view returns (KlineResponse[] memory);
    function getLength() external  view returns (uint256) ;
    // function getCandleInRange(
    //     uint256 fromTimestamp,
    //     uint256 toTimestamp
    // ) external view returns (CandleResponse[] memory);
     function getKlineFrom(uint256 fromTimestamp)
        external
        view
        returns (KlineResponse[] memory);
    // function getKlinesPaginated(uint256 startTimestamp, uint256 limit, uint256 offset) external view  returns (CandleRecord[] memory);
}