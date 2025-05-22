// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interface/IKlineManager.sol";

contract BaseKline is IKlineManager {
    KlineResponse[] private klines; // Sử dụng mảng klines thay vì candles

    address public factory;

    modifier onlyFactory() {
        require(msg.sender == factory, "Not factory");
        _;
    }

    constructor() {
        factory = msg.sender;
    }

    function recordKline(KlineRecord calldata kline) external override {
        // Tạo KlineResponse
        uint256 currentTime = block.timestamp * 1000; // Chuyển block.timestamp sang mili-giây
        KlineResponse memory klineResponse = KlineResponse({
            e: "kline", // Giả định event type
            E: currentTime, // Thời gian ghi nhận (mili-giây)
            s: kline.s, // Symbol
            k: kline
        });

        klines.push(klineResponse);
        emit AddKlineRecord(currentTime, kline.s, kline.o, kline.c);
    }

    function getAllKline()
        external
        view
        override
        returns (KlineResponse[] memory)
    {
        return klines;
    }

    function getLength() public view returns (uint256) {
        return klines.length;
    }
}
