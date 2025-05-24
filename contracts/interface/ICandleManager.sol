// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../struct/CandleStruct.sol";
// Interface for CandleManager
interface ICandleManager {
    // function initData() external;
    function addCandle(CandleRecord memory candle) external ;
    function getCandles () external  view  returns (CandleRecord [] memory );
    // function getLength() external view returns (uint256);
}