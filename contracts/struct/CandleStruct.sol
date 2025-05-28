// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
enum Interval {
    OneSecond,
    OneMinute,
    ThreeMinutes,
    FiveMinutes,
    FifteenMinutes,
    ThirtyMinutes,
    OneHour,
    TwoHours,
    FourHours,
    SixHours,
    EightHours,
    TwelveHours,
    OneDay,
    ThreeDays,
    OneWeek,
    OneMonth
}

struct CandleRecord {
    uint64 openTime;                  // 0: Kline open time (ms timestamp)
    uint openPrice;                // 1: Open price
    uint highPrice;                // 2: High price
    uint lowPrice;                 // 3: Low price
    uint closePrice;               // 4: Close price
    uint volume;                   // 5: Volume
    uint64 closeTime;                // 6: Kline close time (ms timestamp)
    uint quoteAssetVolume;        // 7: Quote asset volume
    uint32 numberOfTrades;          // 8: Number of trades
    uint takerBuyBaseVolume;      // 9: Taker buy base asset volume
    uint takerBuyQuoteVolume;     // 10: Taker buy quote asset volume
    uint unused;                  // 11: Unused field (ignore)
    bool isClose;
}
