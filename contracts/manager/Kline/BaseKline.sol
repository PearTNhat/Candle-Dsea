// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interface/IKlineManager.sol";
import "hardhat/console.sol";
contract BaseKline is IKlineManager {
    string public INTERVAL;
    mapping(uint256 => KlineResponse) private candles; // Lưu trữ nến theo timestamp
    uint256[] private timestampList; // Danh sách timestamp để lấy dữ liệu
    
    constructor(string memory _interval){
        INTERVAL = _interval;
    }

   // Candle[] public candles;
    function recordKline(KlineRecord calldata kline) external override {
        require(keccak256(bytes(kline.i)) == keccak256(bytes(INTERVAL)), "Interval must be 1s");
        uint256 timestamp = kline.t; // Sử dụng startTime làm key
        // Tạo KlineResponse
        uint currentTime =block.timestamp;
        KlineResponse memory klineResponse = KlineResponse({
            e: "kline", // Giả định event type
            E: currentTime, // Thời gian ghi nhận
            s: kline.s, // Symbol
            k: kline
        });

        candles[currentTime] = klineResponse;
        timestampList.push(currentTime);
        // candles.push(KlineResponse);

        emit AddKlineRecord(timestamp, kline.s, kline.o, kline.c);
    }

    function getKline(uint256 timestamp)
        external
        view
        override
        returns (KlineResponse memory)
    {
        return candles[timestamp];
    }

    function getAllKline()
        external
        view
        override
        returns (KlineResponse[] memory)
    {
        KlineResponse[] memory reslut = new KlineResponse[](
            timestampList.length
        );
        for (uint256 i = 0; i < timestampList.length; i++) {
            reslut[i] = candles[timestampList[i]];
        }
        return reslut;
    }

    function getLength() public view returns (uint256) {
        return timestampList.length;
    }

    function getKlineFrom(uint256 fromTimestamp)
        external
        view
        returns (KlineResponse[] memory)
    {
        uint256 count = 0;
        uint256 currentTime = block.timestamp;
        for (uint256 i = 0; i < timestampList.length; i++) {
            uint256 ts = timestampList[i];
            if (ts >= fromTimestamp && ts <= currentTime) {
                count++;
            }
        }
        KlineResponse[] memory result = new KlineResponse[](count);
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
