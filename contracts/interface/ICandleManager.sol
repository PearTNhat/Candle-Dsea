// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../struct/CandleStruct.sol";
// Interface for CandleManager
interface ICandleManager {
    event CandleCreated(
        uint64 openTime,
        string openPrice,
        string highPrice,
        string lowPrice,
        string closePrice,
        string volume,
        uint64 closeTime,
        string quoteAssetVolume,
        uint32 numberOfTrades,
        string takerBuyBaseVolume,
        string takerBuyQuoteVolume,
        bool isClose
    );

    // function initData() external;
    function addCandle(CandleRecord memory candle) external ;
    function getCandles () external  view  returns (CandleRecord [] memory );
    function candleCount() external view returns (uint256);
}