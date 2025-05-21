// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../struct/CandleStruct.sol";
interface ICandleManager {
    event AddCandleRecord(uint256 timestamp, string symbol, uint256 open, uint256 close);
    
    function recordCandle(CandleRecord calldata kline) external;
    function getCandle(uint256 timestamp) external view returns (CandleResponse memory);
    function getLastKline() external view returns (CandleResponse memory);
    function getAllCandle() external  view returns (CandleResponse[] memory);
    // function getKlinesPaginated(uint256 startTimestamp, uint256 limit, uint256 offset) external view  returns (CandleRecord[] memory);
}