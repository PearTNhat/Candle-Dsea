// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct CandleRecord {
    uint64 openTime;                  // 0: Kline open time (ms timestamp)
    string openPrice;                // 1: Open price
    string highPrice;                // 2: High price
    string lowPrice;                 // 3: Low price
    string closePrice;               // 4: Close price
    string volume;                   // 5: Volume
    uint64 closeTime;                // 6: Kline close time (ms timestamp)
    string quoteAssetVolume;        // 7: Quote asset volume
    uint32 numberOfTrades;          // 8: Number of trades
    string takerBuyBaseVolume;      // 9: Taker buy base asset volume
    string takerBuyQuoteVolume;     // 10: Taker buy quote asset volume
    string unused;                  // 11: Unused field (ignore)
}