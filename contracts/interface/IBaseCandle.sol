// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../struct/CandleStruct.sol";
// Interface for CandleManager
interface IBaseCandle {
    function initData() external;
    function getCandle(uint256 index) external view returns (CandleRecord memory);
    function getAllCandles() external view returns (CandleRecord[] memory);
    function getLength() external view returns (uint256);
}