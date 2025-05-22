// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../struct/KlineStruct.sol";
interface IKlineManager {
    event AddKlineRecord(uint256 timestamp, string symbol, string open, string close);
    
    function recordKline(KlineRecord calldata kline) external;
    function getAllKline() external  view returns (KlineResponse[] memory);
    function getLength() external  view returns (uint256) ;
}