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
struct KlineRecord {
    uint256 t;    // startTime
    uint256 T;    // endTime
    string s;    // symbol
    string i;      // interval
    uint256 f;    // firstTradeId
    uint256 L;    // lastTradeId
    string o;    // open
    string c;    // close
    string h;    // high
    string l;    // low
    string v;    // volume
    uint256 n;    // trades
    bool x;       // x (no change since name and comment are the same)
    string q;    // quoteVolume
    string V;    // takerBuyVolume
    string Q;    // takerBuyQuoteVol
    string B;     // ignoredField
}

struct KlineResponse {
    string e; //
    uint E;
    string s ; // symbol
    KlineRecord k;
}