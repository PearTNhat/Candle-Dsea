// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../../interface/ICandleManager.sol";

contract CandleManager is ICandleManager {
    CandleRecord[] private candles;

    address public factory;

    modifier onlyFactory() {
        require(msg.sender == factory, "Not factory");
        _;
    }

    constructor() {
        factory = msg.sender;
    }

    function addCandle(CandleRecord memory candle) external override  onlyFactory {
        candles.push(candle);
    }

    function getCandles () external override onlyFactory view returns  (CandleRecord [] memory ){
        return candles;
    }
    function candleCount() external view returns (uint256) {
        return candles.length;
    }
}
