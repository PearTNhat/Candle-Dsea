// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interface/ICandleManager.sol";

contract Candle_1M_Manager is ICandleManager {
    mapping(uint256 => CandleResponse) private candles; // Lưu trữ nến theo timestamp
    uint256[] private timestampList; // Danh sách timestamp để lấy dữ liệu

    // Candle[] public candles;
    function recordCandle(CandleRecord calldata kline) external override {
        require(kline.t > 0 && kline.T > kline.t, "Invalid time range");
        require(bytes(kline.s).length > 0, "Symbol is required");

        uint256 timestamp = kline.t; // Sử dụng startTime làm key

        // Tạo CandleResponse
        CandleResponse memory candleResponse = CandleResponse({
            e: "kline", // Giả định event type
            E: block.timestamp, // Thời gian ghi nhận
            s: kline.s, // Symbol
            k: kline
        });

        candles[timestamp] = candleResponse;
        timestampList.push(timestamp);
        // candles.push(CandleResponse);

        emit AddCandleRecord(timestamp, kline.s, kline.o, kline.c);
    }

    function getCandle(uint256 timestamp)
        external
        view
        override
        returns (CandleResponse memory)
    {
        return candles[timestamp];
    }

    function getLastKline()
        external
        view
        override
        returns (CandleResponse memory)
    {
        require(timestampList.length > 0, "No candles recorded");
        uint256 lastTimestamp = timestampList[timestampList.length - 1];
        return candles[lastTimestamp];
    }

    function getAllCandle()
        external
        view
        override
        returns (CandleResponse[] memory)
    {
        CandleResponse[] memory result = new CandleResponse[](
            timestampList.length
        );
        for (uint256 i = 0; i < timestampList.length; i++) {
            result[i] = result[timestampList[i]];
        }
        return result;
    }

    function getLength() public view returns (uint256) {
        return timestampList.length;
    }

}
