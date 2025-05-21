// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interface/ICandleManager.sol";

contract Candle_1s_Manager is ICandleManager {
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
        CandleResponse[] memory reslut = new CandleResponse[](
            timestampList.length
        );
        for (uint256 i = 0; i < timestampList.length; i++) {
            reslut[i] = reslut[timestampList[i]];
        }
        return reslut;
    }

    function getLength() public view returns (uint256) {
        return timestampList.length;
    }

    function getCandleInRange(uint256 fromTimestamp, uint256 toTimestamp)
        external
        view
        returns (CandleResponse[] memory)
    {
        require(fromTimestamp < toTimestamp, "Invalid range");

        // Đếm số lượng phù hợp
        uint256 count = 0;
        for (uint256 i = 0; i < timestampList.length; i++) {
            uint256 ts = timestampList[i];
            if (ts >= fromTimestamp && ts <= toTimestamp) {
                count++;
            }
        }

        CandleResponse[] memory result = new CandleResponse[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < timestampList.length; i++) {
            uint256 ts = timestampList[i];
            if (ts >= fromTimestamp && ts <= toTimestamp) {
                result[index] = candles[ts];
                index++;
            }
        }
        return result;
    }
      function getCandleFrom(uint256 fromTimestamp)
        external
        view
        returns (CandleResponse[] memory)
    {
        uint256 count = 0;
        uint currentTime = block.timestamp;
        for (uint256 i = 0; i < timestampList.length; i++) {
            uint256 ts = timestampList[i];
            if (ts >= fromTimestamp && ts <= currentTime) {
                count++;
            }
        }
         CandleResponse[] memory result = new CandleResponse[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < timestampList.length; i++) {
            uint256 ts = timestampList[i];
            if (ts >= fromTimestamp && ts <= currentTime) {
                result[index] = candles[ts];
                index++;
            }
        }
        return result;
    }
}
