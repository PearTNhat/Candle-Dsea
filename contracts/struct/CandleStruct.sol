// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// thiếu name 
struct CandleRecord {
    uint256 t;    // startTime
    uint256 T;    // endTime
    string s;    // symbol
    string i;      // interval
    uint256 f;    // firstTradeId
    uint256 L;    // lastTradeId
    uint256 o;    // open
    uint256 c;    // close
    uint256 h;    // high
    uint256 l;    // low
    uint256 v;    // volume
    uint256 n;    // trades
    bool x;       // x (no change since name and comment are the same)
    uint256 q;    // quoteVolume
    uint256 V;    // takerBuyVolume
    uint256 Q;    // takerBuyQuoteVol
    string B;     // ignoredField
}

struct CandleResponse {
    string e; //
    uint E;
    string s ; // symbol
    CandleRecord k;
}