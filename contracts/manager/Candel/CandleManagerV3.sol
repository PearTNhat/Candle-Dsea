// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../../interface/ICandleManager.sol";

contract CandleManagerV3 is ICandleManager {
    mapping(uint64 => CandleRecord) public candles;
    uint64[] private timestamps;

    address public factory;

    modifier onlyFactory() {
        require(msg.sender == factory, "Not factory");
        _;
    }

    constructor() {
        factory = msg.sender;
    }

    function addCandle(CandleRecord memory candle)
        external
        override
        onlyFactory
    {
        require(candles[candle.openTime].openTime == 0, "Duplicate timestamp");
        candles[candle.openTime] = candle;
        timestamps.push(candle.openTime);
    }

    function getCandles()
        external
        view
        override
        returns (CandleRecord[] memory)
    {
        uint256 total = timestamps.length;
        CandleRecord[] memory result = new CandleRecord[](total);

        for (uint256 i = 0; i < total; i++) {
            uint64 ts = timestamps[total - 1 - i]; // duyệt ngược
            result[i] = candles[ts];
        }
        return result;
    }

    function candleCount() external view override returns (uint256) {
        return timestamps.length;
    }

    function fetchCandlesFromManagers(
        uint64 startTime,
        uint64 endTime,
        uint256 limit
    ) external view returns (CandleRecord[] memory) {
        if (startTime == 0 && endTime == 0) {
            uint256 total = timestamps.length;
            require(total > 0, "No candles available");

            // Chỉ lấy số lượng nến tối đa bằng limit hoặc total
            uint256 fetchCount = limit > total ? total : limit;
            CandleRecord[] memory result = new CandleRecord[](fetchCount);

            for (uint256 i = 0; i < fetchCount; i++) {
                uint64 ts = timestamps[total - 1 - i]; // Lấy từ mới nhất
                result[i] = candles[ts];
            }

            return result;
        } else {
              require(startTime <= endTime, "Invalid time range");

        // Lưu các timestamp hợp lệ
        uint64[] memory validTimestamps = new uint64[](limit);
        uint256 validCount = 0;

        // Duyệt ngược để ưu tiên nến gần hiện tại
        for (uint256 i = timestamps.length; i > 0 && validCount < limit; i--) {
            uint64 ts = timestamps[i - 1];
            if (ts >= startTime && ts <= endTime) {
                validTimestamps[validCount] = ts;
                validCount++;
            }
        }

        // Tạo mảng kết quả với số lượng nến hợp lệ
        CandleRecord[] memory result = new CandleRecord[](validCount);

        // Điền nến vào mảng kết quả, đảo ngược để nến gần hiện tại nằm cuối
        for (uint256 i = 0; i < validCount; i++) {
            result[validCount - 1 - i] = candles[validTimestamps[i]];
        }

        return result;
        }
    }
}
